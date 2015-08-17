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
  end
end
