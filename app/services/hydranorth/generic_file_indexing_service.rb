class Hydranorth::GenericFileIndexingService <  Sufia::GenericFileIndexingService

  def generate_solr_document
    super.tap do |solr_doc|
      if object.thesis?
        solr_doc[Solrizer.solr_name('creator')] = object.dissertant
        solr_doc[Solrizer.solr_name('description')] = object.abstract
      end
    end
  end
end
