module Hydranorth::Collections::CommunitySelection
  extend ActiveSupport::Concern
  include Hydranorth::Collections::BaseQuery

  def find_communities(access_level = nil)
    if access_level.blank?
      perform_collection_query("(#{Solrizer.solr_name('is_community', :stored_searchable, type: :boolean)}:true OR #{Solrizer.solr_name('is_community')}:true) AND (#{Solrizer.solr_name('is_official', :stored_searchable, type: :boolean)}:true OR #{Solrizer.solr_name('is_official')}:true)", access_level)
    else
      perform_collection_query("(#{Solrizer.solr_name('is_community', :stored_searchable, type: :boolean)}:true OR #{Solrizer.solr_name('is_community')}:true) AND (#{Solrizer.solr_name('is_official', :stored_searchable, type: :boolean)}:true OR #{Solrizer.solr_name('is_official')}:true) AND #{Solrizer.solr_name('is_admin_set', :stored_searchable, type: :boolean)}:false", access_level)
    end
  end

  # Sorting by title implemented in hydra-collections v7.0.0 [projecthydra/hydra-collections@e8e57e5] this is a workaround
  def collections_for_community(community_id, access_level = nil)
    perform_collection_query("#{Solrizer.solr_name('belongsToCommunity')}:#{community_id}", access_level)
  end

end
