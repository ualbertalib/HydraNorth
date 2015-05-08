module Hydranorth
  module GenericFile
    module Fedora3Foxml
      extend ActiveSupport::Concern
      included do
        contains "fedora3foxml", class_name: 'Fedora3FoxmlDatastream'
      end

      def old_era?
        !self.fedora3uuid.nil?
      end

    end
  end
end
