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

private
  # Sorting by title implemented in hydra-collections v7.0.0 [projecthydra/hydra-collections@e8e57e5] this is a workaround
  def find_filtered_collections_sorted(access_level = nil)
    # need to know the user if there is an access level applied otherwise we are just doing public collections
    authenticate_user! unless access_level.blank?

    # run the solr query to find the collections
    query = collections_search_builder(access_level).with({q: "#{Solrizer.solr_name('belongsToCommunity')}:#{params[:community_id]}"}).query
    response = repository.search(query)
    # return the user's collections (or public collections if no access_level is applied)

   response.documents.sort do |d1, d2|
     d1.title <=> d2.title
   end 
  end

end
