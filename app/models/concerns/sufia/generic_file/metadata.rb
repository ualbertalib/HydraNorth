module Sufia
  module GenericFile
    module Metadata
      extend ActiveSupport::Concern

      included do

        property :label, predicate: ActiveFedora::RDF::Fcrepo::Model.downloadFilename, multiple: false

        property :depositor, predicate: ::RDF::URI.new("http://id.loc.gov/vocabulary/relators/dpt"), multiple: false do |index|
          index.as :symbol, :stored_searchable
        end

        property :relative_path, predicate: ::RDF::URI.new('http://scholarsphere.psu.edu/ns#relativePath'), multiple: false

        property :import_url, predicate: ::RDF::URI.new('http://scholarsphere.psu.edu/ns#importUrl'), multiple: false do |index|
          index.as :symbol
        end

        property :part_of, predicate: ::RDF::DC.isPartOf
        property :resource_type, predicate: ::RDF::DC.type do |index|
          index.as :stored_searchable, :facetable
        end
        property :title, predicate: ::RDF::DC.title do |index|
          index.as :stored_searchable, :facetable
        end
        property :creator, predicate: ::RDF::DC.creator do |index|
          index.as :stored_searchable, :facetable
        end
        property :contributor, predicate: ::RDF::DC.contributor do |index|
          index.as :stored_searchable, :facetable
        end
        property :description, predicate: ::RDF::DC.description do |index|
          index.type :text
          index.as :stored_searchable
        end
        property :rights, predicate: ::RDF::DC.rights, multiple: false do |index|
          index.as :stored_searchable
        end

        property :publisher, predicate: ::RDF::DC.publisher do |index|
          index.as :stored_searchable, :facetable
        end

        property :date_created, predicate: ::RDF::DC.created, multiple: false do |index|
          index.as :stored_searchable, :stored_sortable
        end

        property :date_modified, predicate: ::RDF::DC.modified, multiple: false do |index|
          index.type :date
          index.as :stored_sortable
        end
        property :subject, predicate: ::RDF::DC.subject do |index|
          index.as :stored_searchable, :facetable
        end

        property :language, predicate: ::RDF::DC.language, multiple: false do |index|
          index.as :stored_searchable, :facetable
        end
        property :identifier, predicate: ::RDF::DC.identifier do |index|
          index.as :stored_searchable
        end
        property :related_url, predicate: ::RDF::DC.relation, multiple: false do |index|
          index.as :stored_searchable
        end
        property :source, predicate: ::RDF::DC.source, multiple: false do |index|
          index.as :stored_searchable
        end
 
      end

    end
  end
end
