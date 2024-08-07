class CreateWatchedBusRoutes < ActiveRecord::Migration[7.1]
  def change
    create_table :watched_bus_routes do |t|
      t.string :email
      t.string :city
      t.string :route_id
      t.string :route_name
      t.integer :direction
      t.string :alert_stop_id

      t.timestamps
    end
  end
end
