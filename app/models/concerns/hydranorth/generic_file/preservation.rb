module Hydranorth
  module GenericFile
    module Preservation
      extend ActiveSupport::Concern

      included do
        after_save :push_noid_for_preservation

        private

        def push_noid_for_preservation
          Hydranorth::PreservationQueue.preserve(self.id)
        end
      end
    end
  end
end
