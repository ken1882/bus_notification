require 'mechanize'

# Github email search
class EmailChecker
  include RequestsHelper

  HTTP_HEADERS = {
    'User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
    'Accept-Language' => 'en-US,en;q=0.9',
    'Upgrade-Insecure-Requests' => '1',
  }

  def initialize
    @agent = Mechanize.new
    @agent.user_agent = HTTP_HEADERS['User-Agent']
    @agent.request_headers = HTTP_HEADERS.dup
  end

  def check(email)
    response = start_requests{ @agent.get("https://api.github.com/search/users?q=#{email}") }
    return true if response.nil?
    return JSON.parse(response.content)['total_count'] > 0
  end
end