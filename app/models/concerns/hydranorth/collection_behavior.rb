module Hydranorth
  module CollectionBehavior
    extend ActiveSupport::Concern
    include Sufia::CollectionBehavior
    include Hydranorth::Collections::Metadata
    include Hydranorth::Collections::Fedora3Foxml
    include Hydra::Collections::Collectible
    include Hydra::Collection
    
    included do
      before_save :remove_self_from_members, :update_permissions
      validates :title, presence: true
      has_and_belongs_to_many :members, predicate:  ActiveFedora::RDF::Fcrepo::RelsExt.hasCollectionMember, class_name: "ActiveFedora::Base"
    end

    def update_permissions
      self.visibility = "open"
      self.edit_groups = self.edit_groups + ['registered']
    end

    def can_be_member_of_collection?(collection)
      collection == self ? false : true
    end

    def remove_self_from_members
      if member_ids.include?(id)
        members.delete(self)
      end
    end

    def Collection.indexer
      Hydranorth::CollectionIndexingService
    end

    def processing?
      false
    end

    def self.find_or_create_with_type(resource_type) 
      cols = []
      Collection.all.each do |c| 
        cols << c if c[:resource_type].include? resource_type 
      end
      begin 
        case cols.length.to_s
        when "1"
          cols.first
        when "0" 
          Collection.new(title: resource_type + " Collection", resource_type: [resource_type])
        else
          raise "More than one #{resource_type} collection exists."
        end
      end
    end

        # Compute the sum of each file in the collection using Solr to
    # avoid having to hit Fedora
    #
    # @return [Fixnum] size of collection in bytes
    # @raise [RuntimeError] unsaved record does not exist in solr
    def bytes
      rows = members.count
      return 0 if rows == 0

      raise "Collection must be saved to query for bytes" if new_record?

      query = ActiveFedora::SolrQueryBuilder.construct_query_for_rel(has_model: file_model)
      args = {
        fq: "{!join from=hasCollectionMember_ssim to=id}id:#{id}",
        fl: "id, #{file_size_field}",
        rows: rows
      }

      files = ActiveFedora::SolrService.query(query, args)
      files.reduce(0) { |sum, f| sum + f[file_size_field].to_i }
    end

    protected

      # Field to look up when locating the size of each file in Solr.
      # Override for your own installation if using something different
      def file_size_field
        Solrizer.solr_name('file_size', stored_integer_descriptor)
      end

      # Override if you are storing your file size in a different way
      def stored_integer_descriptor
        Sufia::GenericFileIndexingService::STORED_INTEGER
      end

      # Override if not using GenericFiles
      def file_model
        ::GenericFile.to_class_uri
      end
 
  end
end
