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
    @filtered_collections = find_filtered_collections_sorted
    @index = params[:index]
    respond_to do |format|
      format.js {}
    end
  end


end
