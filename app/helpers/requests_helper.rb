require 'mechanize'
require 'net/http'

module RequestsHelper
    RETRYABLE_CODES = [
        429, 500, 502, 503, 504
    ].freeze

    RETRYABLE_ERRORS = [
        Net::HTTP::Persistent::Error,
        OpenSSL::SSL::SSLError,
        Timeout::Error,
        Errno::ECONNREFUSED
    ].freeze

    # Requests wrapper capable of retry failed requests
    #
    # @param fallback_proc [Proc] A Proc to call after a retryable failure.
    #   The proc will be called as `proc.call(error, depth_count)`.
    # @param retry_times [Integer] Max number of times to retry.
    def start_requests(fallback_proc=nil, retry_times=5)
        depth = 0
        begin
            yield # execute given block
        rescue Mechanize::ResponseCodeError => e
            depth += 1
            raise e if depth > retry_times
            raise e unless RETRYABLE_CODES.include? e.response_code
            fallback_proc.call(e, depth) if fallback_proc
            retry
        rescue *RETRYABLE_ERRORS => e
            @_last_error = e
            depth += 1
            raise if depth > retry_times
            fallback_proc.call(e, depth)
            retry
        end
    end
end
