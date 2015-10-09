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
      end

      def visibility_with_institutions=(value) 
        return (self.visibility_without_institutions = value) unless INSTITUTIONAL_PROVIDERS.include? value
        return set_institutional_visibility!(value)
      end

      def institutional_visibility?
        (read_groups & INSTITUTIONAL_PROVIDERS).present?
      end

      private

      def set_institutional_visibility!(institution)
        # institutional visibility is a subset of registered visibility
        registered_visibility!
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
