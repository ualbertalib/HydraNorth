require "./lib/rdf_vocabularies/ualterms"
require "./lib/rdf_vocabularies/ualid"

module Hydranorth
  module GenericFile
    module Metadata
      extend ActiveSupport::Concern
      included do

        # We reserve date_uploaded for the original creation date of the record.
        # For example, when migrating data from a fedora3 repo to fedora4,
        # fedora's system created date will reflect the date when the record
        # was created in fedora4, but the date_uploaded will preserve the
        # original creation date from the old repository.
        property :date_uploaded, predicate: ActiveFedora::RDF::Fcrepo::Model.createdDate, multiple: false do |index|
          index.type :date
          index.as :stored_sortable
        end

        property :license, predicate: ::RDF::DC.license, multiple: false do |index|
          index.as :stored_searchable
        end
        property :trid, predicate: ::UALId.trid, multiple: false do |index|
          index.as :stored_searchable, :sortable
        end
        property :ser, predicate: ::UALId.ser, multiple: false do |index|
          index.as :stored_searchable, :sortable
        end

        property :temporal, predicate: ::RDF::DC.temporal  do |index|
          index.as :stored_searchable, :facetable
        end

        property :spatial, predicate: ::RDF::DC.spatial do |index|
          index.as :stored_searchable, :facetable
      	end

        property :is_version_of, predicate: ::RDF::DC.isVersionOf, multiple:false do |index|
          index.as :stored_searchable
        end

        property :unicorn, predicate: ::UALId.unicorn, multiple: false do |index|
          index.as :stored_searchable
        end

        property :fedora3uuid, predicate: ::UALId.fedora3uuid, multiple: false do |index|
          index.as :symbol, :stored_searchable
        end

        property :fedora3handle, predicate: ::UALId.fedora3handle, multiple: false do |index|
          index.as :symbol, :stored_searchable
        end

        property :ingestbatch, predicate: ::UALTerms.ingestbatch, multiple: false do |index|
          index.as :stored_searchable
        end

        property :hasCollection, predicate: ::UALTerms.hasCollection do |index|
          index.as :symbol, :stored_searchable
        end

        property :belongsToCommunity, predicate: ::UALTerms.belongsToCommunity, multiple: true do |index|
          index.as :symbol, :stored_searchable
        end

        property :hasCollectionId, predicate: ::UALTerms.hasCollectionId do |index|
          index.as :symbol, :stored_searchable
        end

        property :ark_created, predicate: ::UALTerms.ark_created, multiple: false do |index|
          index.type :boolean
          index.as :stored_searchable
        end

        property :ark_id, predicate: ::UALId.ark_id, multiple: false do |index|
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

        property :remote_resource, predicate: ::UALTerms.remote_resource, multiple:false

      end

      def belongsToCommunity?
        !self.belongsToCommunity.empty?
      end

    end
  end
end
