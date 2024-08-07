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

  def initialize
    super
    self.request_headers = DEFALT_HTTP_HEADERS.dup
  end

  def do_requests(method, *args, **kwargs)
    # swap proxy if failed (probably rate limited)
    retry_msg = "%s %s\nSwapping proxy and retrying...(depth=%d)"
    fallback = Proc.new do |e, depth|
      Rails.logger.error(sprintf(retry_msg, e.class.name, e.message, depth))
      WildProxy.next_proxy(self)
    end
    # add url-safe odata query string
    odata_params = DEFALT_ODATA_PARAM.merge(kwargs.delete(:odata) || {})
    URI.method(:encode_uri_component).tap do |m|
      args[0] += '?' + odata_params.map{|k,v| "#{m.call k}=#{m.call v}"}.join('&')
    end
    # send requests
    start_requests(fallback) do
      self.send(method, *args, **kwargs)
    end
  end

  def get_city_routes(city)
    response = do_requests(:get, "#{HOST}/api/basic/v2/Bus/DisplayStopOfRoute/City/#{city}")
    JSON.parse(response.content)
  end

  def get_realtime_route(city, route_name)
    response = do_requests(:get, "#{HOST}/api/basic/v2/Bus/EstimatedTimeOfArrival/City/#{city}/#{route_name}")
    JSON.parse(response.content)
  end
end
