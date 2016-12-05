module Hydranorth
  module GenericFile
    module DOIStates
      extend ActiveSupport::Concern

      included do
        after_save :handle_doi_states
        before_destroy :withdraw_doi

        attr_accessor :skip_handle_doi_states

        include AASM

        aasm do
          state :not_available, initial: true
          state :unminted
          state :excluded
          state :available
          state :awaiting_update

          event :created, after: :queue_create_job do
            transitions from: :not_available, to: :unminted
          end

          event :removed do
            transitions from: :not_available, to: :excluded
          end

          event :unpublish do
            transitions from: [:excluded, :awaiting_update, :unminted], to: :not_available
          end

          event :synced do
            transitions from: [:unminted, :awaiting_update], to: :available
          end

          event :altered, after: :queue_update_job do
            transitions from: [:available, :not_available], to: :awaiting_update
          end
        end

        def doi_permanent_url
          "https://doi.org/#{doi.gsub(/doi:/, '')}" if doi.present?
        end

        def doi_fields_present?
          # TODO: Shouldn't have to do this as these are required fields on the UI.
          # However since no data integrity a GF without these fields is technically valid... have to double check
          self && title.present? && creator.present? && resource_type.present? && Sufia.config.admin_resource_types[resource_type.first].present?
        end

        private

        def withdraw_doi
          DOIRemovalJob.perform_later(doi) if doi.present?
        end

        def handle_doi_states
          if skip_handle_doi_states.blank?
            return if !doi_fields_present?

            if doi.blank? # Never been minted before
              if !private? && not_available?
                created!(id)
              end
            else
              # If private, we only care if visibility has been made public
              # If public, we care if visibility changed to private or doi fields have been changed
              if (not_available? && transitioned_from_private?) ||
                (available? && (doi_fields_changed? || transitioned_to_private?))
                altered!(id)
              end
            end
          else
            self.skip_handle_doi_states = false
          end
        end

        def doi_fields_changed?
          [:title, :creator, :year_created, :resource_type].any? do |k|
            if previous_changes.key?(k)
              # check if the changes are actually different
              return true if previous_changes[k][0] != previous_changes[k][1]
            end
          end
          false
        end

        def queue_create_job(generic_file_id)
          DOIServiceJob.perform_later(generic_file_id, 'create')
        end

        def queue_update_job(generic_file_id)
          DOIServiceJob.perform_later(generic_file_id, 'update')
        end
      end
    end
  end
end
