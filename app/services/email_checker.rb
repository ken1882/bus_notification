require 'mechanize'

# 3rd party API to check email address
# unused but reserved for further possible usage
class EmailChecker

  HTTP_HEADERS = {
    'User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
    'Accept-Language' => 'en-US,en;q=0.9',
    'Origin' => 'https://email-checker.net',
    'Referer' => 'https://email-checker.net/check',
    'Upgrade-Insecure-Requests' => '1',
  }

  attr_reader :agent, :csrf_token, :last_error

  def initialize
    @agent = Mechanize.new
    @agent.user_agent = HTTP_HEADERS['User-Agent']
    @agent.request_headers = HTTP_HEADERS.dup
    @csrf_token = nil
    @last_error = ''
  end

  def extract_token(page=nil)
    page = @agent.get('https://email-checker.net/') if page.nil?
    node = page.search('input[name="_csrf"]').first
    return if node.nil?
    @csrf_token = node['value']
  end

  def submit_query(email)
    response = @agent.post(
      'https://email-checker.net/check',
      {
        'email': email,
        '_csrf': @csrf_token,
        'v': 'v37',
        'g-recaptcha-response-data[check]': '',
        'g-recaptcha-response': '',
      },
      HTTP_HEADERS.merge({
        'Content-Type' => 'application/x-www-form-urlencoded'
      })
    )
    extract_token(response)
    node = response.search('div[class="summary"]').first
    @last_error = node.nil? ? 'blocked' : node.text
    return :error if node.nil? || node.text =~ /Limit/i
    return :ok    if node.text =~ /Result.*OK/i
    return :bad
  end

  def validate_email(email)
    extract_token unless @csrf_token
    return submit_query(email)
  end
end