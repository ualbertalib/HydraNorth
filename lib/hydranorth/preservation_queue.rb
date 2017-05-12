module Hydranorth::PreservationQueue

  QUEUE_NAME = YAML.load(File.read('config/preservation.yml'))[Rails.env]['queue_name']

  def queue
    $queue ||= ConnectionPool.new({size: 1, timeout: 5}) { Redis.new }
  end

  def preserve(noid)
    queue.with do |conn|
      conn.zadd QUEUE_NAME, Time.now.to_f, noid
    end
  end

  module_function :preserve, :queue

end
