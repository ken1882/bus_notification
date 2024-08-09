env :PATH, ENV['PATH']
set :output, "log/cron_output.log"
set :environment, ENV['RAILS_ENV']

every 1.minute do
  runner "Api::V1::WatchedRoutesController.update_bus_live"
end

