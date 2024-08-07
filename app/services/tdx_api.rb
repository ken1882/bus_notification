require 'mechanize'
require 'brotli'
require 'json'

class TdxApi < Mechanize
  include RequestsHelper

  HOST = 'https://tdx.transportdata.tw'

  DEFALT_HTTP_HEADERS = {
    'Accept' => 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/png,image/svg+xml,*/*;q=0.8',
    'User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
    'Accept-Language' => 'en-US,en;q=0.9',
    'Accept-Encoding' => 'gzip, deflate, br, zstd',
    'Upgrade-Insecure-Requests' => '1',
  }

  # will add in url query string
  DEFALT_ODATA_PARAM = {
    '$format' => 'JSON'
  }
  
  AUTH_ENABLED = !!ENV['TDX_CLIENT_ID']

  # shared cached token for workers
  CACHE_TOKEN_KEY = 'tdx_auth_token'
  CACHE_LOCK_KEY  = 'tdx_auth_lock'
  CACHE_LOCK_TTL  = 60_000 # 1min

  def initialize
    super
    self.request_headers = DEFALT_HTTP_HEADERS.dup
    self.sync_auth_token
  end

  def change_token(token)
    if token
      self.request_headers['authorization'] = "Bearer #{token}"
    else
      self.request_headers.delete 'authorization'
    end
  end

  # Sync token between workers, get new one if unavailable
  def sync_auth_token
    return false unless AUTH_ENABLED
    token = $redis.get(CACHE_TOKEN_KEY)
    return change_token(token) if token
    $redlock.lock(CACHE_LOCK_KEY, CACHE_LOCK_TTL) do |locked|
      if locked
        begin
          response = get_auth_token(ENV['TDX_CLIENT_ID'], ENV['TDX_CLIENT_SECRET'])
          token = response['access_token']
          ttl = response['expires_in'] - 30
          $redis.set(CACHE_TOKEN_KEY, token, ex: ttl)
        ensure
          $redlock.unlock(locked) if locked
        end
      else
        sleep 0.1 until token = $redis.get(CACHE_TOKEN_KEY)
      end
    end
    return change_token(token)
  end

  # Will return parsed json response if success, otherwise `false`
  def get_auth_token(app_id, app_key)
    ori_headers = self.request_headers.dup
    self.request_headers = {}
    response = self.do_requests(
      :post,
      "#{HOST}/auth/realms/TDXConnect/protocol/openid-connect/token",
      {
        'content-type' => 'application/x-www-form-urlencoded',
        'grant_type' => 'client_credentials',
        'client_id' => app_id,
        'client_secret' => app_key,
      },
      odata: {}
    )
    self.request_headers = ori_headers
    begin
      File.open('log/tmp.log') do |fp|
        fp.write("Response:\n#{response.body}") rescue nil
        fp.write("Response:\n#{response.page}") rescue nil
      end
      return JSON.parse(response.content)
    rescue Exception => e
      Rails.logger.error("Error processing auth (#{e}).Response:\n#{response}")
    end
    Rails.logger.warn("Failed to get TDX auth token.Response:\n#{response}")
    return false
  end

  def do_requests(method, *args, **kwargs)
    # failure callbacks
    retry_msg = "%s %s\nSwapping proxy and retrying...(depth=%d)"
    fallback = Proc.new do |e, depth|
      Rails.logger.error(sprintf(retry_msg, e.class.name, e.message, depth))
      # use auth token if exists, otherwise proxy
      auth_ok = self.sync_auth_token
      if !auth_ok
        self.change_token(nil)
        WildProxy.next_proxy(self) # no sensitive data so should be fine
      end
    end
    # add url-safe odata query string
    odata_params = kwargs.delete(:odata) || DEFALT_ODATA_PARAM
    URI.method(:encode_www_form_component).tap do |m|
      args[0] += '?' + odata_params.map{|k,v| "#{m.call k}=#{m.call v}"}.join('&')
    end
    # return send result
    start_requests(fallback){ self.send(method, *args, **kwargs) }
  end

  def get_city_routes(city)
    response = do_requests(:get, "#{HOST}/api/basic/v2/Bus/Route/City/#{city}")
    return JSON.parse(response.content)
  end

  def get_live_route(city, route_name)
    response = do_requests(:get, "#{HOST}/api/basic/v2/Bus/EstimatedTimeOfArrival/City/#{city}/#{route_name}")
    return JSON.parse(response.content)
  end

end
