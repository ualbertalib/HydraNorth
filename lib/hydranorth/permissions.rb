module Hydranorth
  module Permissions
    extend ActiveSupport::Autoload
    include Sufia::Permissions
    autoload :Writable
  end
end
