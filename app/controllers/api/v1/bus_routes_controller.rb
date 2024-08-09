module Api::V1
  class BusRoutesController < ApplicationController
    include CityConstants
    include ApplicationValidator
    before_action :validate_city, only: [:show, :route_show]
  
    # GET /bus_routes
    # shows all available city
    def index
      render json: { result: CityConstants::CITIES }
    end
  
    # GET /bus_routes/:city
    # shows all routes and stops info of given city
    def show
      page = params[:page].to_i
      cache_key = "bus_routes_show_#{params[:city]}@#{page}"
      @bus_route = Rails.cache.fetch(cache_key, expires_in: 1.hour) do
        TdxApi.new.get_city_routes params[:city], page
      end
      render json: { error: 'Invalid parameter' }, status: :bad_request if @bus_route.nil?
      has_more = @bus_route.size == TdxApi::DEFALT_ODATA_PARAM['$top']
      @bus_route.pop if has_more
      render json: { result: @bus_route, has_more: has_more}
    end
  
    # GET /bus_routes/:city/routes/:route_name
    # get route status
    def route_show
      page = params[:page].to_i
      cache_key = "bus_routes_show_#{params[:city]}_#{params[:route_name]}@#{page}"
      @realtime_route = Rails.cache.fetch(cache_key, expires_in: 1.minute) do
        TdxApi.new.get_live_route params[:city], params[:route_name], page
      end
      render json: { error: 'Invalid parameter' }, status: :bad_request if @realtime_route.nil?
      has_more = @realtime_route.size == TdxApi::DEFALT_ODATA_PARAM['$top']
      @realtime_route.pop if has_more
      render json: { result: @realtime_route, has_more: has_more}
    end
  
    private
  
    def validate_city
      p params
      return if valid_city? params[:city]
      render json: { error: 'Invalid city code' }, status: :bad_request
    end
  
  end
end