module Hydranorth::Collections::CollectionSelection
  extend ActiveSupport::Concern
  include Hydranorth::Collections::BaseQuery

  def find_collections(access_level = nil)
    perform_collection_query("(-#{Solrizer.solr_name('is_community', :stored_searchable, type: :boolean)}:true AND -#{Solrizer.solr_name('is_community')}:true) AND (#{Solrizer.solr_name('is_official', :stored_searchable, type: :boolean)}:true OR #{Solrizer.solr_name('is_official')}:true)", access_level)
  end

  def find_collections_grouped_by_community(access_level = nil)
    collections = find_collections(access_level)
    # filter out collections in a community that are nested in a collection
    collections.reject! {|c| c[Solrizer.solr_name('hasCollection')].present? || c[Solrizer.solr_name('hasCollectionId')].present?}
    grouped_user_collections = collections.group_by { |c| c[Solrizer.solr_name('belongsToCommunity')] }

    return collections, grouped_user_collections
  end
end
