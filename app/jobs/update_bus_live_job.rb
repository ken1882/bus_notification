# Live bus data watchdog
class UpdateBusLiveJob < ApplicationJob
  include BusConstants
  queue_as :default

  ALERT_SECONDS_THRESHOLD = 180

  def perform(*args)
    city, route_name = args.flatten
    has_more, page = true, 0
    @realtime_routes = []
    @agent = TdxApi.new
    while has_more
      cache_key = "bus_routes_show_#{city}_#{route_name}@#{page}"
      routes = Rails.cache.fetch(cache_key, expires_in: 1.minute) do
        @agent.get_live_route(city, route_name, page)
      end
      page += 1
      has_more = routes.size == TdxApi::DEFALT_ODATA_PARAM['$top']
      routes.pop if has_more
      @realtime_routes += routes
    end
    # iterate through routes and sending matching watched routes
    @realtime_routes.each do |route|
      next if route['StopStatus'] != StopStatus[:normal]
      next if !route['EstimateTime'] || route['EstimateTime'] > ALERT_SECONDS_THRESHOLD
      Rails.logger.debug("Notify incoming bus: #{city} #{route_name} #{route['StopName']['Zh_tw']}(#{route['Direction']} #{route['StopID']})")
      # prevent sending multiple notification of same bus
      curt = Time.current
      timestamp_threashold = curt - ALERT_SECONDS_THRESHOLD.seconds
      WatchedBusRoute.where(
        city: city,
        route_name: route_name,
        direction: route['Direction'],
        alert_stop_id: route['StopID'],
      ).where('last_notify_time < ?', timestamp_threashold).each do |model|
        model.update(last_notify_time: curt)
        NotificationHelper.notify_bus_incoming(model, city, route)
      end
    end
  end
end
