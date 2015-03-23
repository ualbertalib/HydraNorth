module Hydranorth
  module BatchControllerBehavior
    extend ActiveSupport::Concern
    include Sufia::BatchControllerBehavior

    included do 
      class_attribute :edit_form_class
      self.edit_form_class = Hydranorth::Forms::BatchEditForm
    end


  end
end
