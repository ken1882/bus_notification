class AddLastNotifyTimeToWatchedBusRoutes < ActiveRecord::Migration[7.1]
  def change
    add_column :watched_bus_routes, :last_notify_time, :datetime
  end
end
