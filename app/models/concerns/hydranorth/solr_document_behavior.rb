# -*- encoding : utf-8 -*-
module Hydranorth 
  module SolrDocumentBehavior
    extend ActiveSupport::Concern
    include Sufia::SolrDocumentBehavior
    
    def subjects
      Array(self[Solrizer.solr_name("subject")])
    end

  end
end
