module Hydranorth::PreservationQueue

  class PreservationError < StandardError; end

  QUEUE_NAME = Rails.application.secrets.preservation_queue_name

  def queue
    $queue ||= ConnectionPool.new({size: 1, timeout: 5}) { Redis.new }
  end

  def preserve(noid)
    queue.with do |conn|
      status = conn.zadd QUEUE_NAME, Time.now.to_f, noid
      raise PreservationError unless status == true
    end
    # rescue all preservation errors so that the user can continue to use the application normally
  rescue StandardError => e
    Rollbar.error("Could not preserve #{noid}", e)
  end

  module_function :preserve, :queue

end
