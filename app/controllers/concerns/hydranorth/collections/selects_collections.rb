module Hydranorth::Collections::SelectsCollections
  extend ActiveSupport::Concern
  include Blacklight::Catalog
  include Hydra::Collections::SelectsCollections
  include Hydranorth::Permissions


  def collections_search_builder_class
    ::CollectionSearchBuilder
  end

  def access_levels
    { read: [:read, :edit], edit: [:edit] }
  end

  def find_communities_with_read_access
    find_communities(:read)
  end

  def find_communities_with_edit_access
    find_communities(:edit)
  end

 # need to check for _tesim and _bsi in solr query because ActiveFedora does not allow false to be passed
 def find_collections(access_level = nil)
    # need to know the user if there is an access level applied otherwise we are just doing public collections
    authenticate_user! unless access_level.blank?

    # run the solr query to find the collections
    query = collections_search_builder(access_level).with({q: '(-is_community_bsi:true AND -is_community_tesim:true) AND (is_official_bsi:true OR is_official_tesim:true)'}).query
    response = repository.search(query)
    # return the user's collections (or public collections if no access_level is applied)

   @user_collections = response.documents.sort do |d1, d2|
     d1.title <=> d2.title
   end
 end

 def find_collections_grouped_by_community(access_level = nil)
   find_collections(access_level)
   @grouped_user_collections = @user_collections.group_by { |c| c["#{Solrizer.solr_name('belongsToCommunity')}"] }
 end

 # need to check for _tesim and _bsi in solr query because ActiveFedora does not allow false to be passed
 def find_communities(access_level = nil)
    # need to know the user if there is an access level applied otherwise we are just doing public collections
    authenticate_user! unless access_level.blank?

    # run the solr query to find the collections
    if access_level.blank?
      query = collections_search_builder(access_level).with({q: '(is_community_bsi:true OR is_community_tesim:true) AND (is_official_bsi:true OR is_official_tesim:true) '}).query
    else
      query = collections_search_builder(access_level).with({q: '(is_community_bsi:true OR is_community_tesim:true) AND (is_official_bsi:true OR is_official_tesim:true) AND is_admin_set_bsi:false'}).query
    end
    response = repository.search(query)
    # return the user's collections (or public collections if no access_level is applied)
    # not a fan of sorting this in ruby, but collections search builder doesn't seem to pass on
    # sort params properly
    @user_communities = response.documents.sort do |d1, d2|
      d1.title <=> d2.title
    end
  end

  # Sorting by title implemented in hydra-collections v7.0.0 [projecthydra/hydra-collections@e8e57e5] this is a workaround
  def collections_for_community(community_id, access_level = nil)
    # need to know the user if there is an access level applied otherwise we are just doing public collections
    authenticate_user! unless access_level.blank?

    # run the solr query to find the collections
    query = collections_search_builder(access_level).with({q: "#{Solrizer.solr_name('belongsToCommunity')}:#{community_id}"}).query
    response = repository.search(query)
    # return the user's collections (or public collections if no access_level is applied)

    response.documents.sort do |d1, d2|
     d1.title <=> d2.title
    end
  end
end
