require 'redis'
Redis.current = Redis.new(url: ENV['REDIS_URL'] || Rails.application.secrets.redis_url)
