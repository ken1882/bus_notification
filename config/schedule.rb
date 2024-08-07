set :output, "log/cron_output.log"

every 1.minute do
  runner "WatchedRoutesController.update_bus_live"
end

