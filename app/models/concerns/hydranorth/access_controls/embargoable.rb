module Hydranorth
  module AccessControls
    module Embargoable
      extend ActiveSupport::Concern
      include Hydra::AccessControls::Embargoable

      included do
        alias_method_chain :visibility, :embargo
      end

      def visibility_with_embargo
        return Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_EMBARGO if under_embargo?
        return visibility_without_embargo
      end
    end
  end
end
