# -*- encoding : utf-8 -*-
module Hydranorth
  module SolrDocumentBehavior
    extend ActiveSupport::Concern
    include Sufia::SolrDocumentBehavior

    def subjects
      Array(self[Solrizer.solr_name("subject")])
    end

    def date_created
      Array(self[Solrizer.solr_name("date_created")]).first
    end

    def date_created?
      !self[Solrizer.solr_name("date_created")].nil?
    end

    def abstract
      Array(self[Solrizer.solr_name('abstract')]).first
    end

    def dissertant
      Array(self[Solrizer.solr_name('dissertant')]).first
    end

    def doi_url
      doi = self[Solrizer.solr_name('doi_url')]
      return doi.first if doi.present? && !doi.first.nil? && doi.first != 'false'
      return nil
    end

    def doi_url_indexed?
      self.has_key?(Solrizer.solr_name('doi_url'))
    end
  end
end
