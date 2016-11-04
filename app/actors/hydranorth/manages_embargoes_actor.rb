module Hydranorth
  #  To use this module, include it in your Actor class
  #  and then add its interpreters wherever you want them to run.
  #  They should be called _before_ apply_attributes is called because
  #  they intercept values in the attributes Hash.
  #
  #  @example
  #  class MyActorClass < BaseActor
  #     include Worthwile::ManagesEmbargoesActor
  #
  #     def create
  #       interpret_visibility && super && copy_visibility
  #     end
  #
  #     def update
  #       interpret_visibility && super && copy_visibility
  #     end
  #  end
  #
  module ManagesEmbargoesActor
    extend ActiveSupport::Concern

    # Interprets embargo & lease visibility if necessary
    # returns false if there are any errors
    def interpret_visibility
      interpret_embargo_visibility && interpret_lease_visibility
    end

    # If user has set visibility to embargo, interprets the relevant information and applies it
    # Returns false if there are any errors and sets an error on the curation_concern
    def interpret_embargo_visibility
      if attributes[:visibility] != Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_EMBARGO
        # clear embargo_release_date even if it isn't being used. Otherwise it sets the embargo_date
        # even though they didn't select embargo on the form.
        attributes.delete(:visibility_during_embargo)
        attributes.delete(:visibility_after_embargo)
        attributes.delete(:embargo_release_date)

        # if GenericFile's current visibility is embargo, then the new non-embargo visibility is overwriting it
        # and we need to deactivate
        if generic_file.visibility == Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_EMBARGO
          generic_file.deactivate_embargo!
          generic_file.embargo.save if generic_file.embargo
        end

        generic_file.visibility = attributes[:visibility]
        true
      elsif !attributes[:embargo_release_date]
        generic_file.errors.add(:visibility, 'When setting visibility to "embargo" you must also specify embargo release date.')
        false
      else
        attributes.delete(:visibility)
        generic_file.apply_embargo(attributes[:embargo_release_date], attributes.delete(:visibility_during_embargo),
                  attributes.delete(:visibility_after_embargo))
        if generic_file.embargo
          generic_file.embargo.save
        end
        generic_file.save
        true
      end
    end

    # If user has set visibility to lease, interprets the relevant information and applies it
    # Returns false if there are any errors and sets an error on the curation_concern
    def interpret_lease_visibility
      if attributes[:visibility] != Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_LEASE
        # clear lease_expiration_date even if it isn't being used. Otherwise it sets the lease_expiration
        # even though they didn't select lease on the form.
        attributes.delete(:visibility_during_lease)
        attributes.delete(:visibility_after_lease)
        attributes.delete(:lease_expiration_date)

        # if GenericFile's current visibility is lease, then the new non-lease visibility is overwriting it
        # and we need to deactivate
        if generic_file.visibility == Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_LEASE
          generic_file.deactivate_lease!
          generic_file.lease.save if generic_file.lease
        end
        generic_file.visibility = attributes[:visibility]
        true
      elsif !attributes[:lease_expiration_date]
        generic_file.errors.add(:visibility, 'When setting visibility to "lease" you must also specify lease expiration date.')
        false
      else
        generic_file.apply_lease(attributes[:lease_expiration_date], attributes.delete(:visibility_during_lease),
                                       attributes.delete(:visibility_after_lease))
        if generic_file.lease
          generic_file.lease.save  # See https://github.com/projecthydra/hydra-head/issues/226
        end
        attributes.delete(:visibility)
        true
      end
    end


  end
end
