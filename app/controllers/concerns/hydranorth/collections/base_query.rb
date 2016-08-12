module Hydranorth::Collections::BaseQuery
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

  def perform_collection_query(query_string, access_level)
    authenticate_user! unless access_level.blank?

    # run the solr query to find the collections
    query = collections_search_builder(access_level).with({q: query_string}).query
    response = repository.search(query)
    # return the user's collections (or public collections if no access_level is applied)

    response.documents
  end
end
