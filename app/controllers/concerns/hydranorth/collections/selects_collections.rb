module Hydranorth::Collections::SelectsCollections
  extend ActiveSupport::Concern
  include Hydra::Collections::SelectsCollections
  include Hydranorth::Permissions
  
  def access_levels
    { read: [:read, :edit], edit: [:edit] }
  end 
  def find_communities_with_read_access
    find_communities(:read)
  end

  def find_communities_with_edit_access
    find_communities(:edit)
  end


  def find_communities(access_level = nil)
    # need to know the user if there is an access level applied otherwise we are just doing public collections
    authenticate_user! unless access_level.blank?

    # run the solr query to find the collections
    query = collections_search_builder(access_level).with({q: 'is_community_bsi:true'}).query
    response = repository.search(query)
    # return the user's collections (or public collections if no access_level is applied)
    # not a fan of sorting this in ruby, but collections search builder doesn't seem to pass on 
    # sort params properly
    @user_communities = response.documents.sort do |d1, d2|
      d1.title <=> d2.title
    end
  end
end
