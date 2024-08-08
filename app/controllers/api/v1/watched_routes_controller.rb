module Api::V1
  class WatchedRoutesController < ApplicationController
    include CityConstants
    include ApplicationValidator
    before_action :validate_city, only: [:create]
  
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
      render json: watched_routes
    end
  
    # POST /watched_routes/add
    # Add a new watched route
    def create
      route_params = create_params
      route_params[:last_notify_time] = Time.current
      watched_route = WatchedBusRoute.new(route_params)
  
      if watched_route.save
        render json: watched_route, status: :created
      else
        render json: watched_route.errors, status: :bad_request
      end
    end
  
    # DELETE /watched_routes/remove
    # Remove a watched route
    def destroy
      route_params = delete_params
      watched_route = WatchedBusRoute.find_by(email: route_params[:email], route_id: route_params[:route_id])
  
      if watched_route
        watched_route.destroy
        head :no_content
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
      params.permit(:email, :destroy)
    end
    
    def validate_city
      return if valid_city? params[:city]
      render json: { error: 'Invalid city code' }, status: :bad_request
    end
  
  end  
end