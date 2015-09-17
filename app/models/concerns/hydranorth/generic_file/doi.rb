module Hydranorth
  module GenericFile
    module DOI 
      extend ActiveSupport::Concern
      include Linkable
      included do
      end

      def doi_url
        self.identifier.first if ((!self.identifier.first.nil?) && (linkable? self.identifier.first))
      end

    end
  end
end
