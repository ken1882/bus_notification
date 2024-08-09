ENV.each { |k, v| env(k, v) }
set :output, {:standard => "#{path}/log/cron.log", :error => "#{path}/log/cron_error.log"}
set :environment, ENV['RAILS_ENV']

every 1.minutes do
  command "cd #{path} && bin/rails runner 'Api::V1::WatchedRoutesController.update_bus_live'"
end 
