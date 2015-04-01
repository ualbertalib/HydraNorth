module Hydranorth 
  class CollectionIndexingService < ActiveFedora::IndexingService 
    def generate_solr_document
      super.tap do |solr_doc|
        solr_doc = object.index_collection_ids(solr_doc)
      end
    end
  end
end
