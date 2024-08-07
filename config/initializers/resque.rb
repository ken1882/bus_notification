require 'resque'
require 'redis'

# Configure Redis connection
Resque.redis = Redis.new(url: ENV["REDIS_URL"].split(',').first)
