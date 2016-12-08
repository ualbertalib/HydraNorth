module Hydranorth
  module AccessControls
    module InstitutionalVisibility
      extend ActiveSupport::Concern
      include Hydranorth::AccessControls::Embargoable

      INSTITUTIONAL_PROVIDER_MAPPING = YAML.load(File.read('config/institutional_providers.yml'))
      INSTITUTIONAL_PROVIDERS = INSTITUTIONAL_PROVIDER_MAPPING.values
      INSTITUTIONAL_PROVIDERS.each do |provider|
        self.const_set(provider.upcase, provider)
      end

      included do
        alias_method_chain :visibility=, :institutions
        # set up revocation of Institutional Visibility when changing to another
        # visibility
        alias_method_chain :public_visibility!, :institutions
        alias_method_chain :registered_visibility!, :institutions
        alias_method_chain :private_visibility!, :institutions
        alias_method_chain :embargo_visibility!, :institutions

        alias :institutional_access? :institutional_visibility?


        # aliases for visibility lifecycle visibility
        alias_method_chain :visibility_will_change!, :lifecycle_hooks

      end

      def visibility_with_institutions=(value)
        return (self.visibility_without_institutions = value) unless INSTITUTIONAL_PROVIDERS.include? value
        return set_institutional_visibility!(value)
      end


      # hooks for visibility lifecycle visibility
      # TODO hoist these out into a separate module

      def visibility_will_change_with_lifecycle_hooks!
        @visibility_lifecycle_previous_state = visibility
        visibility_will_change_without_lifecycle_hooks!
      end

      def previous_visibility
        return @visibility_lifecycle_previous_state
      end

      def transitioned_from_private?
        private_visibility_text =  Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
        return previous_visibility == private_visibility_text && visibility != private_visibility_text
      end

      def transitioned_to_private?
        private_visibility_text = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
        return previous_visibility != private_visibility_text && visibility == private_visibility_text
      end

      # end visibility lifecycle hooks

      def institutional_visibility?
        (read_groups & INSTITUTIONAL_PROVIDERS).present?
      end


      private

      def set_institutional_visibility!(institution)
        visibility_will_change!
        # institutional visibility is a subset of public visibility
        public_visibility!
        set_read_groups([institution],[])
      end

      def revoke_institutional_visibility!
        set_read_groups([], INSTITUTIONAL_PROVIDERS)
      end

      def public_visibility_with_institutions!
        revoke_institutional_visibility!
        public_visibility_without_institutions!
      end

      def registered_visibility_with_institutions!
        revoke_institutional_visibility!
        registered_visibility_without_institutions!
      end

      def private_visibility_with_institutions!
        revoke_institutional_visibility!
        private_visibility_without_institutions!
      end

      def embargo_visibility_with_institutions!
        revoke_institutional_visibility!
        embargo_visibility_without_institutions!
      end
    end
  end
end
