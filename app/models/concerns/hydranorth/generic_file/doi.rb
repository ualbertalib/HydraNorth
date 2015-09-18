module Hydranorth
  module GenericFile
    module DOI 
      include Linkable

      def doi_url
        self.identifier.first if ((!self.identifier.first.nil?) && (linkable? self.identifier.first))
      end

    end
  end
end
