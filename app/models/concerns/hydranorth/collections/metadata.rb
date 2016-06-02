require "./lib/rdf_vocabularies/ualterms"
require "./lib/rdf_vocabularies/ualid"

module Hydranorth::Collections
  module Metadata
    extend ActiveSupport::Concern
    included do
      property :license, predicate: RDF::DC.license, multiple:false do |index|
        index.as :stored_searchable
      end
      property :fedora3uuid, predicate: ::UALId.fedora3uuid, multiple: false do |index|
        index.as :symbol, :stored_searchable
      end

      property :fedora3handle, predicate: ::UALId.fedora3handle, multiple: false do |index|
        index.as :symbol, :stored_searchable
      end

      property :belongsToCommunity, predicate: ::UALTerms.belongsToCommunity, multiple: true do |index|
        index.as :symbol, :stored_searchable
      end

      property :is_community, predicate: ::UALTerms.is_community, multiple: false do |index|
        index.type :boolean
        index.as :stored_searchable
      end

      property :is_official, predicate: ::UALTerms.is_official, multiple: false do |index|
        index.type :boolean
        index.as :stored_searchable
      end

      property :is_admin_set, predicate: ::UALTerms.is_admin_set, multiple: false do |index|
        index.type :boolean
        index.as :stored_searchable
      end

      property :hasCollectionMember, predicate: ActiveFedora::RDF::Fcrepo::RelsExt.hasCollectionMember, multiple: true

    end
  end
end
