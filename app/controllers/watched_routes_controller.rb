class WatchedRoutesController < ApplicationController
  include CityConstants
  before_action :validate_country, only: [:create]
  before_action :validate_country, only: [:get, :create, :destroy]

  # POST /watched_routes/get
  # Get list of watched routes by email
  def get
  end

  # POST /watched_routes/add
  def create
  end

  # DELETE /watched_routes/remove
  def destroy
  end
  
  private
  def get_params
    params.permit(:email)
  end

  def create_params
    params.permit(:email, :city, :route_id, :stop_id, :direction)
  end

  def delete_params
    params.permit(:email, :destroy)
  end
end
