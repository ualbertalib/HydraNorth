class Hydranorth::GenericFileIndexingService <  Sufia::GenericFileIndexingService
  include LinkUtils

  def generate_solr_document
    super.tap do |solr_doc|
      if object.thesis?
        solr_doc[Solrizer.solr_name('creator')] = object.dissertant
        solr_doc[Solrizer.solr_name('description')] = object.abstract
      end
      if object.doi.present?
        Solrizer.insert_field(solr_doc, 'doi_without_label', object.doi.gsub('doi:', ''), :symbol)
      end
      solr_doc[Solrizer.solr_name('doi_url')] = if object.identifier.first.present? && linkable?(object.identifier.first)
        object.identifier.first
      else
        'false'
      end
      Solrizer.insert_field(solr_doc, 'sortable_title', object.title.first.downcase, :stored_sortable) if object.title && !object.title.empty?
    end
  end
end
