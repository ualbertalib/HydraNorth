module Hydranorth
  module FilesController
    extend ActiveSupport::Autoload
    include Sufia::FilesController
  end

  module FilesControllerBehavior
    extend ActiveSupport::Concern
    include Hydranorth::Collections::SelectsCollections
    include Sufia::FilesControllerBehavior
    include Hydranorth::Breadcrumbs


    included do
      self.edit_form_class = Hydranorth::Forms::GenericFileEditForm
      self.presenter_class = Hydranorth::GenericFilePresenter
    end

    def update
      success =
        if wants_to_revert?
          update_version
        elsif wants_to_upload_new_version?
          update_file
        elsif params.key? :generic_file
          update_metadata
        elsif params.key? :visibility
          update_visibility
        end

      if success
        ezid = Hydranorth::EzidService.new()
        ezid.modify(@generic_file)

        redirect_to sufia.edit_generic_file_path(tab: params[:redirect_tab]), notice:
          render_to_string(partial: 'generic_files/asset_updated_flash', locals: { generic_file: @generic_file })
      else
        flash[:error] ||= 'Update was unsuccessful.'
        set_variables_for_edit_form
        render action: 'edit'
      end
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
      find_collections_with_read_access
      find_communities_with_read_access
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
