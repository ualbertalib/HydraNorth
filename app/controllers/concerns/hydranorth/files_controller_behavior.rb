module Hydranorth
  module FilesController
    extend ActiveSupport::Autoload
    include Sufia::FilesController
  end
  module FilesControllerBehavior
    extend ActiveSupport::Concern
    include Sufia::FilesControllerBehavior
    include Hydranorth::Breadcrumbs

  included do
    self.edit_form_class = Hydranorth::Forms::GenericFileEditForm
    self.presenter_class = Hydranorth::GenericFilePresenter
  end
    protected
   def actor
      @actor ||= Hydranorth::GenericFile::Actor.new(@generic_file, current_user, attributes)
   end
    
    def attributes
      attributes = params
    end


  end

end
