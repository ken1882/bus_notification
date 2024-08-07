class WatchedRoutesController < ApplicationController
  include CityConstants
  before_action :validate_country, only: [:create]
  before_action :validate_country, only: [:get, :create, :destroy]
  before_action :validate_city, only: [:create]

  def self.update_bus_live
    registered_routes = WatchedBusRoute.distinct.pluck(:city, :route_name)
    slice_size = [registered_routes.size / Rails.configuration.x.default_worker_cnt, 1].max
    registered_routes.each_slice(slice_size) do |pairs|
      UpdateBusLiveJob.perform_later(pairs)
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
    watched_route = WatchedBusRoute.find_by(email: route_params[:email], id: route_params[:route_id])

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
    params.permit(:email, :city, :route_id, :stop_id, :direction, :alert_stop_id)
  end

  def delete_params
    params.permit(:email, :destroy)
  end
end
