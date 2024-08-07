class BusRoutesController < ApplicationController
  include CityConstants
  before_action :validate_country, only: [:show, :route_show]

  # GET /bus_routes/:city
  # shows all routes and stops info of given city
  def show
    cache_key = "bus_routes_show_#{params[:city]}"
    @bus_route = Rails.cache.fetch(cache_key, expires_in: 1.hour) do
      # Make the API call to fetch bus route for the city
      # move this to corn job and updates per hour
      # https://tdx.transportdata.tw/api/basic/v2/Bus/DisplayStopOfRoute/City/#{city}?%24format=JSON
    end
    render json: @bus_route
  end

  # GET /bus_routes/:city/routes/:route_name
  # get route status
  def route_show
    cache_key = "bus_routes_show_#{params[:city]}_#{params[:route_name]}"
    @bus_route = Rails.cache.fetch(cache_key, expires_in: 1.minute) do
      # Make the API call to fetch bus route for the city
      # https://tdx.transportdata.tw/api/basic/v2/Bus/EstimatedTimeOfArrival/City/#{city}/#{route_name}?%24format=JSON
    end
    render json: @bus_route
  end

end