module Hydranorth
  module GenericFile
    module Era1Stats 
      extend ActiveSupport::Concern
      included do
        contains "era1stats", class_name: 'Era1StatsDatastream'
      end

    end
  end
end
