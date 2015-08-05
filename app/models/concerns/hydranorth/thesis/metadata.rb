require "./lib/rdf_vocabularies/ualterms"

module Hydranorth 
  module Thesis
    module Metadata
      extend ActiveSupport::Concern

      vivo = RDF::Vocabulary.new("http://vivoweb.org/ontology/core#")
      bibo = RDF::Vocabulary.new("http://purl.org/ontology/bibo/")
      included do

        property :degree_grantor, predicate: ::RDF::Vocab::MARCRelators.dgg, multiple: false do |index|
          index.as :stored_searchable
        end
        property :dissertant, predicate: ::RDF::Vocab::MARCRelators.dis, multiple: false do |index|
          index.as :stored_searchable
        end

        property :supervisor, predicate: ::RDF::Vocab::MARCRelators.ths do |index|
          index.as :stored_searchable
        end
        property :committee_member, predicate: ::UALTerms.thesiscommitteemember do |index|
          index.as :stored_searchable
        end
        property :department, predicate: vivo.AcademicDepartment, multiple: false do |index|
          index.as :stored_searchable
        end
        property :specialization, predicate: ::UALTerms.specialization, multiple: false do |index|
          index.as :stored_searchable
        end
        property :date_submitted, predicate: ::RDF::DC.dateSubmitted, multiple: false do |index|
          index.type :date
          index.as :stored_searchable
        end
        property :date_accepted, predicate: ::RDF::DC.dateAccepted, multiple: false do |index|
          index.type :date
          index.as :stored_searchable
        end
        property :graduation_date, predicate: ::UALTerms.graduationdate, multiple: false do |index|
          index.as :stored_searchable, :facetable
        end
        property :alternative_title, predicate: ::RDF::DC.alternative do |index|
          index.as :stored_searchable
        end
        property :thesis_name, predicate: bibo.ThesisDegree, multiple: false do |index|
          index.as :stored_searchable
        end
        property :thesis_level, predicate: ::UALTerms.thesislevel, multiple: false do |index|
          index.as :stored_searchable
        end

        property :proquest, predicate: ::UALTerms.proquest, multiple: false do |index|
          index.as :stored_searchable
        end
        property :abstract, predicate: ::RDF::DC.abstract, multiple: false do |index|
          index.as :stored_searchable
        end
      end

    end
  end
end
