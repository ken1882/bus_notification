require "test_helper"

class WatchedBusRouteTest < ActiveSupport::TestCase

  def setup
    generate_data
  end

  def generate_data(cnt=4)
    attr_generator = {
      :email => Proc.new{SecureRandom.alphanumeric(8).downcase+'@kimo.com'},
      :city  => CityConstants::CITIES,
      :route_id => Proc.new{SecureRandom.alphanumeric(4)},
      :route_name => Proc.new{SecureRandom.alphanumeric(4)},
      :direction => Proc.new{(rand*10).to_i%2},
      :alert_stop_id => Proc.new{SecureRandom.alphanumeric(4)},
    }

    cnt.times do
      fields = {}
      attr_generator.each do |k, v|
        val = v
        val = v.sample if v.respond_to? :sample
        val = v.call   if v.respond_to? :call
        fields[k] = val
      end
      WatchedBusRoute.create(fields)
    end
  end
  # test "the truth" do
  #   assert true
  # end
end
