require "./lib/rdf_vocabularies/ualterms"

module Hydranorth 
  module GenericFile
    module Metadata
      extend ActiveSupport::Concern
      included do

        property :license, predicate: ::RDF::DC.license, multiple: false do |index|
          index.as :stored_searchable
        end
        property :trid, predicate: ::UALTerms.trid, multiple: false do |index|
          index.as :stored_searchable, :sortable
        end
        property :ser, predicate: ::UALTerms.ser, multiple: false do |index|
          index.as :stored_searchable, :sortable
        end
        
        property :temporal, predicate: ::RDF::DC.temporal, multiple:false do |index|
          index.as :stored_searchable, :facetable
        end

        property :spatial, predicate: ::RDF::DC.spatial, multiple:false do |index|
          index.as :stored_searchable, :facetable
      	end

        property :is_version_of, predicate: ::RDF::DC.isVersionOf, multiple:false do |index|
          index.as :stored_searchable
        end

        property :unicorn, predicate: ::UALTerms.unicorn, multiple: false do |index|
          index.as :stored_searchable
        end
       
        property :proquest, predicate: ::UALTerms.proquest, multiple: false do |index|
          index.as :stored_searchable
        end

        property :fedora3uuid, predicate: ::UALTerms.fedora3uuid, multiple: false do |index|
          index.as :stored_searchable
        end

        property :fedora3handle, predicate: ::UALTerms.fedora3handle, multiple: false do |index|
          index.as :stored_searchable
        end

        property :ingestbatch, predicate: ::UALTerms.ingestbatch, multiple: false do |index|
          index.as :stored_searchable
        end

        property :hasCollection, predicate: ::UALTerms.hasCollection do |index|
          index.as :symbol, :stored_searchable
        end

        begin
          LocalAuthority.register_vocabulary(self, "spatial", "geonames_cities")
        rescue
          puts "tables for vocabularies missing"
        end

        property :year_created, predicate: ::UALTerms.year_created, multiple: false do |index|
          index.type :date 
          index.as :stored_searchable, :facetable
        end


      end

    end
  end
end
