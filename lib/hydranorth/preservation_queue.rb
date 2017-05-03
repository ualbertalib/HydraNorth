module Hydranorth::PreservationQueue

  def preserve(noid)
    redis.with do |conn|
      conn.zadd 'dev:pmpy_queue', Time.now.to_f, noid
      # make sure 'OK' or log
    end
  end

  def redis
    $redis ||= ConnectionPool.new { Redis.new }
  end

  module_function :preserve, :redis

end
