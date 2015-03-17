module Hydranorth
  module BatchControllerBehavior
    extend ActiveSupport::Concern
    include Sufia::BatchControllerBehavior

    included do 
      class_attribute :edit_form_class
      self.edit_form_class = Hydranorth::Forms::BatchEditForm
    end

    def edit
      @batch = Batch.find_or_create(params[:id])
      @form = edit_form
    end


    def update
      authenticate_user!
      @batch = Batch.find_or_create(params[:id])
      @batch.status = ["processing"]
      @batch.save
      file_attributes = edit_form_class.model_attributes(params[:generic_file])
      logger.debug "Controller: file params #{params[:generic_file]}" 
      logger.debug "Controller: file_attributes #{file_attributes}"
      Sufia.queue.push(BatchUpdateJob.new(current_user.user_key, params[:id], params[:title], file_attributes, params[:visibility]))
      flash[:notice] = 'Your files are being processed by ' + t('sufia.product_name') + ' in the background. The metadata and access controls you specified are being applied. Files will be marked <span class="label label-danger" title="Private">Private</span> until this process is complete (shouldn\'t take too long, hang in there!). You may need to refresh your dashboard to see these updates.'
      if uploading_on_behalf_of? @batch
        redirect_to sufia.dashboard_shares_path
      else
        redirect_to sufia.dashboard_files_path
      end
    end
    protected

    def edit_form
      generic_file = ::GenericFile.new(creator: [current_user.name], title: @batch.generic_files.map(&:label))
      edit_form_class.new(generic_file)
    end

  end
end
