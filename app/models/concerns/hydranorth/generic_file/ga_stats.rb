module Hydranorth
  module GenericFile
    module GaStats 
      extend ActiveSupport::Concern
      included do
        contains "gastats", class_name: 'GaStatsDatastream'
      end

    end
  end
end
