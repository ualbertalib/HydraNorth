module Hydranorth
  module BatchEditsControllerBehavior
    extend ActiveSupport::Concern
    include Hydranorth::Breadcrumbs
    include Sufia::BatchEditsControllerBehavior

    def redirect_to_return_controller
      if params[:return_controller]
        redirect_to url_for(controller: params[:return_controller], only_path: true)
      else
        redirect_to sufia.dashboard_files_path
      end
    end
    #This override is for Sufia 6.2. Issue is fixed in Sufia 7 and this will not be needed.
    def update_document(obj)
      super
      obj.date_modified = Time.current.ctime
    end

    protected

    def terms
      Hydranorth::Forms::BatchEditForm.terms
    end

    def generic_file_params
      Hydranorth::Forms::BatchEditForm.model_attributes(params[:generic_file])
    end

  end
end
