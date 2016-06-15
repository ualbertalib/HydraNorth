module Hydranorth
  module Collections
    module Logo 
      extend ActiveSupport::Concern
      included do
        contains "logo", class_name: 'LogoDatastream'
      end

    end
  end
end
