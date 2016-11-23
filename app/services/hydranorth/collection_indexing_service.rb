module Hydranorth
  class CollectionIndexingService < ActiveFedora::IndexingService
    def generate_solr_document
      super.tap do |solr_doc|
        # TODO: index_collection_ids is deprecated
        solr_doc = object.index_collection_ids(solr_doc)
        Solrizer.insert_field(solr_doc, 'sortable_title', object.title.downcase, :stored_sortable)
      end
    end
  end
end
