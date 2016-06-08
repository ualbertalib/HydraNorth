class GenericFilesController < ApplicationController
  include Hydranorth::FilesControllerBehavior

  warn "[DEPRECATION] `Batch` will change substantially with the introduction of `Hydra::Works`. When this occurs #new can be removed from GenericFilesController"

  # TODO This is a temporary override of sufia to fix #
  #      This can be removed once sufia has a solution and we upgrade or
  #      batches are no longer used when sufia migrates to PCDM
  # routed to /files/new
  def new
    @batch_id  = Batch.create.id
  end


  # on edit pages required to filter collections based on selected community
  def update_collections
    @filtered_collections = collections_for_community(params[:community_id])
    @index = params[:index]
    respond_to do |format|
      format.js {}
    end
  end

  def cstr_resource?
    @generic_file[:resource_type].include? Sufia.config.special_types['cstr']
  end
  
  def ser_resource?
    @generic_file[:resource_type].include? Sufia.config.special_types['ser']
  end

  def dataverse_resource?
    @generic_file[:remote_resource] == "dataverse" 
  end

  def thesis_resource?
    @generic_file[:resource_type].include? Sufia.config.special_types['thesis']
  end

  def presenter_class
    super unless @generic_file
    return Hydranorth::CstrPresenter if cstr_resource?
    return Hydranorth::SerPresenter if ser_resource?
    return Hydranorth::DataversePresenter if dataverse_resource?
    return Hydranorth::ThesisPresenter if thesis_resource?
    Hydranorth::GenericFilePresenter
  end

  def edit_form_class
    super unless @generic_file
    return Hydranorth::Forms::CstrEditForm if cstr_resource?
    return Hydranorth::Forms::SerEditForm if ser_resource?
    return Hydranorth::Forms::ThesisEditForm if thesis_resource?
    Hydranorth::Forms::GenericFileEditForm
  end

end
