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

  def perform_collection_query(query_string, access_level, sort_order='sortable_title_ssi asc')
    authenticate_user! unless access_level.blank?
    query_elements = {q: query_string}

    # This seems silly, but
    # we need to pass the sort order through the search_builder because it does some sort-key demangling, but
    # SearchBuilder#query fails to include the sort order in the final query, which I THINK is a bug, so we have to
    # put the demangled version back in anyways.
    query_elements[:sort] = sort_order if sort_order.present?

    search_builder = collections_search_builder(access_level).with(query_elements)
    sort = search_builder.sort
    query = search_builder.query
    query[:sort] = sort if sort.present?

    response = repository.search(query)

    response.documents
  end
end
