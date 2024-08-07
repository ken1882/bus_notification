class ApplicationController < ActionController::API
    def validate_city
        return if valid_city? params[:city]
        render json: { error: 'Invalid city code' }, status: :bad_requests
    end


    def validate_email
        return if valid_email? params[:email]
        render json: { error: 'Invalid email' }, status: :bad_requests
    end

    private

    def valid_city?(city)
        return CityConstants::Cities.include? CityConstants::Cities
    end

    def valid_email?(email)
        return email =~ /^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$/
    end
end
