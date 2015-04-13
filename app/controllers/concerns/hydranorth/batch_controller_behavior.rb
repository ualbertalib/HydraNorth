module Hydranorth
  module BatchControllerBehavior
    extend ActiveSupport::Concern
    include Sufia::BatchControllerBehavior

    included do 
      class_attribute :edit_form_class, :cstr_edit_form_class, :ser_edit_form_class
      self.edit_form_class = Hydranorth::Forms::BatchEditForm
      self.cstr_edit_form_class = Hydranorth::Forms::CstrBatchEditForm
      self.ser_edit_form_class = Hydranorth::Forms::SerBatchEditForm
    end

    def edit
      @batch = Batch.find_or_create(params[:id])
      @form = edit_form
      @form[:resource_type] = @batch.generic_files.map(&:resource_type).flatten
    end 
    

    def update
      authenticate_user!
      @batch = Batch.find_or_create(params[:id])
      @batch.status = ["processing"]
      @batch.save
      resource_type = @batch.generic_files.map(&:resource_type).flatten
      if resource_type.include? Sufia.config.special_reports['cstr']
        @collection = Collection.find(Sufia.config.cstr_collection_id)
        add_to_collection
      elsif resource_type.include? Sufia.config.special_reports['ser']
        @collection = Collection.find(Sufia.config.ser_collection_id)
        add_to_collection
      end
      file_attributes = Hydranorth::Forms::BatchEditForm.model_attributes(params[:generic_file])
      Sufia.queue.push(BatchUpdateJob.new(current_user.user_key, params[:id], params[:title], params[:trid], params[:ser], file_attributes, params[:visibility]))
      flash[:notice] = 'Your files are being processed by ' + t('sufia.product_name') + ' in the background. The metadata and access controls you specified are being applied. Files will be marked <span class="label label-danger" title="Private">Private</span> until this process is complete (shouldn\'t take too long, hang in there!). You may need to refresh your dashboard to see these updates.'
      if uploading_on_behalf_of? @batch
        redirect_to sufia.dashboard_shares_path
      else
        redirect_to sufia.dashboard_files_path
      end
    end

    protected
    def add_to_collection
      @batch.generic_files.each do |gf|
      @collection.member_ids = @collection.member_ids.push(gf.id)
      @collection.save
    end
 
    end
    def edit_form
      generic_file = ::GenericFile.new(creator: [current_user.name], title: @batch.generic_files.map(&:label))
      resource_type = @batch.generic_files.map(&:resource_type).flatten
      if resource_type.include? Sufia.config.special_reports['cstr']
        cstr_edit_form_class.new(generic_file)
      elsif resource_type.include? Sufia.config.special_reports['ser']
        ser_edit_form_class.new(generic_file)
      else
        edit_form_class.new(generic_file)
      end

    end


  end
end
