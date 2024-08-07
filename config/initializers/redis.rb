require 'redis'
require 'redlock'

$redis = Redis.new(url: ENV["REDIS_URL"].split(',').first)
$redlock = Redlock::Client.new ENV["REDIS_URL"].split(',')
