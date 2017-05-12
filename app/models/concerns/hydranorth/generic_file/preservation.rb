module Hydranorth
  module GenericFile
    module Preservation
      extend ActiveSupport::Concern

      included do
        after_save :push_noid_for_preservation

        private

        def push_noid_for_preservation
          res = Hydranorth::PreservationQueue.preserve(self.id)
          Rails.logger.warn("Could not preserve #{self.id}") unless res == true
          # TODO: <removed temporarily> log to external service iff res != true
          return true
        rescue StandardError
          # we trap errors in writing to the Redis queue in order to avoid crashing the save process
          # for the user. TODO: This should raise any errors to an external notificaiton service
          return true
        end
      end
    end
  end
end
