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

    def filename
      return Array(self[Solrizer.solr_name('filename')]) if self.has_key?(Solrizer.solr_name('filename'))

      # we can try to fish it out of the object profile, but this is kind of a hack
      # if it doesn't work, we just return a link to the show page. This should be less
      # necessary after the re-index
      begin
        # cache this, as it can get called repeatedly on the same object and
        # parsing JSON is relatively expensive (though cheaper than a trip to Fedora)
        @json ||= JSON.parse(self['object_profile_ssm'].first)
        return @json['filename'] if @json.has_key?('filename') && @json['filename'].present?
      rescue
        # this would be a good place for hoptoad/airbrake/newrelic-style alerting
        # this should indicate either a corrupted object cache in Solr or an object
        # without an attached file. We return nil and deal with this in the caller
        return nil
      end
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
