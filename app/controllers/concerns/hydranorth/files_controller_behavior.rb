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

    def presenter
     
      if @generic_file[:resource_type].include? Sufia.config.special_types['cstr'] 
        Hydranorth::CstrPresenter.new(@generic_file)
      elsif @generic_file[:resource_type].include? Sufia.config.special_types['ser']
        Hydranorth::SerPresenter.new(@generic_file)
      elsif @generic_file[:remote_resource] == "dataverse"
        Hydranorth::DataversePresenter.new(@generic_file)
      elsif @generic_file[:resource_type].include? Sufia.config.special_types['thesis']
        Hydranorth::ThesisPresenter.new(@generic_file)
      else
        Hydranorth::GenericFilePresenter.new(@generic_file)
      end
    end

    def edit_form
       
      if @generic_file[:resource_type].include? Sufia.config.special_types['cstr']
        Hydranorth::Forms::CstrEditForm.new(@generic_file) 
      elsif @generic_file[:resource_type].include? Sufia.config.special_types['ser']
        Hydranorth::Forms::SerEditForm.new(@generic_file)
      elsif @generic_file[:resource_type].include? Sufia.config.special_types['thesis']
        Hydranorth::Forms::ThesisEditForm.new(@generic_file)
      else
        Hydranorth::Forms::GenericFileEditForm.new(@generic_file)
      end
    end
    def process_file(file)

      Batch.find_or_create(params[:batch_id])

      update_metadata_from_upload_screen
      update_resource_type_from_upload_screen
      if params[:resource_type].present?
         actor.create_metadata_with_resource_type(params[:batch_id], params[:resource_type]) 
      else
         actor.create_metadata(params[:batch_id])
      end
      if actor.create_content(file, file.original_filename, file_path, file.content_type)
        respond_to do |format|
          format.html {
            render 'jq_upload', formats: 'json', content_type: 'text/html'
          }
          format.json {
            render 'jq_upload'
          }
        end
      else
        msg = @generic_file.errors.full_messages.join(', ')
        flash[:error] = msg
        json_error "Error creating generic file: #{msg}"
      end
    end
    def update_resource_type_from_upload_screen
      # Relative path is set by the jquery uploader when uploading a directory
      @generic_file.resource_type = [Sufia.config.special_types['cstr']] if params[:resource_type] == Sufia.config.special_types['cstr'] 
      @generic_file.resource_type = [Sufia.config.special_types['ser']] if params[:resource_type] == Sufia.config.special_types['ser'] 
    end
  end

end
