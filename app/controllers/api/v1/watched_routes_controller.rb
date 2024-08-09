module Api::V1
  class WatchedRoutesController < ApplicationController
    include CityConstants
    include ApplicationValidator
    before_action :validate_city, only: [:create]
    before_action :validate_email, only: [:get, :create, :destroy]
    before_action :check_email_exists, only: [:create]
    
    WATCHED_LIMIT = 10

    # called by scheduler
    def self.update_bus_live
      registered_routes = WatchedBusRoute.distinct.pluck(:city, :route_name)
      Rails.logger.debug("Live update queued: #{registered_routes}\n")
      registered_routes.each do |pair|
        UpdateBusLiveJob.perform_later(pair)
      end
    end
  
    # POST /watched_routes/get
    # Get list of watched routes by email
    def get
      email = get_params[:email]
      watched_routes = WatchedBusRoute.where(email: email)
      render json: { result: watched_routes }
    end
  
    # POST /watched_routes/add
    # Add a new watched route
    def create
      route_params = create_params
      if WatchedBusRoute.where(email: route_params[:email]).count >= WATCHED_LIMIT
        render json: { error: 'Watched routes limit reached' }, status: :too_many_requests
      end
      watched_route = WatchedBusRoute.new(route_params)

      if !watched_route.validate
        render json: { error: watched_route.errors }, status: :bad_request
      elsif WatchedBusRoute.find_by(route_params)
        render json: { result: 'Already exists' }, status: :ok
      else
        watched_route.last_notify_time = Time.current
        watched_route.save
        render json: { result: watched_route }, status: :created
      end
    end
  
    # DELETE /watched_routes/remove
    # Remove a watched route
    def destroy
      watched_route = WatchedBusRoute.find_by(delete_params)
      if watched_route
        watched_route.destroy
        render json: { result: 'Deleted' }, status: :ok
      else
        render json: { error: 'Watched route not found' }, status: :not_found
      end
    end
    
    private
    def get_params
      params.permit(:email)
    end
  
    def create_params
      params.permit(
        :email,
        :city,
        :route_id,
        :route_name,
        :direction,
        :alert_stop_id
      )
    end
  
    def delete_params
      params.permit(:email, :route_id, :direction, :alert_stop_id)
    end
    
    def validate_city
      return if valid_city? params[:city]
      render json: { error: 'Invalid city code' }, status: :bad_request
    end

    def validate_email
      return if valid_email? params[:email]
      render json: { error: 'Invalid email' }, status: :bad_request
    end
    
    def check_email_exists
      return if EmailChecker.new.check(params[:email])
      render json: { error: 'Email unreachable, is this your actual email address?' }, status: :bad_request
    end

  end  
end