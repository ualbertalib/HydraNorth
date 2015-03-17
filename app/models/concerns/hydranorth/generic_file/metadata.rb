require "./lib/rdf_vocabularies/dams"

module Hydranorth 
  module GenericFile
    module Metadata
      extend ActiveSupport::Concern
      included do

        property :license, predicate: ::RDF::DC.license, multiple: false do |index|
          index.as :stored_searchable
        end
        property :trid, predicate: ::DamsVocabulary.trid, multiple: false do |index|
          index.as :stored_searchable, :sortable
        end
        property :ser, predicate: ::DamsVocabulary.ser, multiple: false do |index|
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
      end

    end
  end
end
