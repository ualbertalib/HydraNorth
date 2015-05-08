require "./lib/rdf_vocabularies/ualterms"

module Hydranorth::Collections
  module Metadata
    extend ActiveSupport::Concern
    included do
      property :license, predicate: RDF::DC.license, multiple:false do |index|
        index.as :stored_searchable
      end
      property :fedora3uuid, predicate: ::UALTerms.fedora3uuid, multiple: false do |index|
        index.as :stored_searchable
      end

      property :fedora3handle, predicate: ::UALTerms.fedora3handle, multiple: false do |index|
        index.as :stored_searchable
      end


    end
  end
end
