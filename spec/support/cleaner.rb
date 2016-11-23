module Cleaner
  require 'active_fedora/cleaner'

  def cleanup_jetty
    ActiveFedora::Cleaner.clean!
  end

  RSpec.configure do |config|
    config.include Cleaner
  end
end
