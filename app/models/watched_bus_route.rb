class WatchedBusRoute < ApplicationRecord
  validates :email, presence: true
  validates :city, presence: true
  validates :route_id, presence: true
  validates :route_name, presence: true
  validates :direction, presence: true
  validates :alert_stop_id, presence: true
end
