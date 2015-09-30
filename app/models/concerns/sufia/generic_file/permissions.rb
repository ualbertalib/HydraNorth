module Sufia
  module GenericFile
    module Permissions
      extend ActiveSupport::Concern

      include Hydranorth::Permissions::Writable
      include Sufia::Permissions::Readable
    end
  end
end
