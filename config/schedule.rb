set :output, "log/cron_output.log"

every 1.minute do
  runner "Api::V1::WatchedRoutesController.update_bus_live"
end

