module Hydranorth 
  module Forms
    class CollectionEditForm
      include HydraEditor::Form
      self.model_class = ::Collection
      self.terms = [:title, :resource_type, :creator, :description, :license]
      self.required_fields = [:title, :license ]
      # Test to see if the given field is required
      # @param [Symbol] key a field
      # @return [Boolean] is it required or not
      def required?(key)
        model_class.validators_on(key).any?{|v| v.kind_of? ActiveModel::Validations::PresenceValidator}
      end
    end
  end
end
