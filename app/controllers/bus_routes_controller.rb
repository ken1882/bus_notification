class BusRoutesController < ApplicationController
  include CityConstants
  before_action :validate_country, only: [:show, :route_show]

  # GET /bus_routes/:city
  # shows all routes and stops info of given city
  def show
    cache_key = "bus_routes_show_#{params[:city]}"
    @bus_route = Rails.cache.fetch(cache_key, expires_in: 1.hour) do
      ret = TdxApi.new.get_city_routes city
    end
    render json: @bus_route
  end

  # GET /bus_routes/:city/routes/:route_name
  # get route status
  def route_show
    cache_key = "bus_routes_show_#{params[:city]}_#{params[:route_name]}"
    @realtime_route = Rails.cache.fetch(cache_key, expires_in: 1.minute) do
      ret = TdxApi.new.get_realtime_route params[:city], params[:route_name]
    end
    render json: @realtime_route
  end

end