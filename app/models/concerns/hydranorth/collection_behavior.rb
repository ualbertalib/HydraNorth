module Hydranorth
  module CollectionBehavior
    extend ActiveSupport::Concern
    include Sufia::ModelMethods
    include Sufia::Noid
    include Sufia::GenericFile::Permissions
    include Hydranorth::Collections::Metadata
    include Hydranorth::Collections::Fedora3Foxml
    include Hydra::Collections::Collectible
    include Hydra::AccessControls::Permissions
    include Hydra::Collections::Metadata
    include Hydranorth::Collections::Logo

    included do
      before_save :remove_self_from_members, :update_permissions, :check_logo_size
      validates :title, presence: true
    end

    class_methods do
      def find_or_create_with_type(resource_type)
        cols = []
        Collection.all.each do |c|
          cols << c if c[:resource_type].include? resource_type
        end
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
 
    def check_logo_size
      size = logo.size
      if size.to_i > 200.kilobytes
        raise "Collection logo larger than 200KB"
      end
    end  

    def update_permissions
      self.visibility = "open"
      self.edit_groups = self.edit_groups + ['registered'] unless self.is_admin_set? || !self.is_official?
    end

    def is_admin_set?
      self.is_admin_set ||= false
    end

    def is_official?
      self.is_official ||= false
    end

    def is_community?
      self.is_community ||= false
    end

    def belongsToCommunity?
      !self.belongsToCommunity.empty?
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

    def member_ids
      hasCollectionMember.map do |member_activetriple|
        member_id = member_activetriple.is_a?(String) ? member_activetriple : member_activetriple.id
        member_id.gsub(/http:.*\//, '')
      end
    end

    def member_ids=(arr)
      add_member_ids(arr)
    end

    def members=(arr)
      member_ids = arr.map(&:id)
    end

    def members
      query = {
        fq: "(-hasCollectionId_ssim:[* TO *] AND (belongsToCommunity_ssim:#{id} OR belongsToCommunity_tesim:#{id})) OR hasCollectionId_ssim:#{id}"
      }

      response = Blacklight.default_index.search(query)

      response.documents
    end

    def member_count
      hasCollectionMember.length
    end


    # Compute the sum of each file in the collection using Solr to
    # avoid having to hit Fedora
    #
    # @return [Fixnum] size of collection in bytes
    # @raise [RuntimeError] unsaved record does not exist in solr
    def bytes
      rows = member_count

      return 0 if rows == 0

      raise "Collection must be saved to query for bytes" if new_record?

      query = ActiveFedora::SolrQueryBuilder.construct_query_for_rel(has_model: file_model)
      args = {
        fq: "(-hasCollectionId_ssim:[* TO *] AND (belongsToCommunity_ssim:#{id} OR belongsToCommunity_tesim:#{id})) OR hasCollectionId_ssim:#{id}",
        fl: "id, #{file_size_field}",
        rows: rows
      }

      files = ActiveFedora::SolrService.query(query, args)
      files.reduce(0) { |sum, f| sum + f[file_size_field].to_i }
    end

    # returns an array of the materialized ActiveFedora objects for
    # all members. Note that this is very very expensive for our large
    # collections. You should prefer calling Collection#members
    # which returns a SolrQuery
    def materialized_members
      ActiveFedora::Base.find(member_ids)
    end

    def add_member(new_member)
      add_members [new_member]
    end

    def add_members(new_members)
      return if new_members.nil? || new_members.size < 1
      add_member_ids new_members.map(&:id)
    end

    def add_member_ids(new_member_ids)
      return if new_member_ids.nil? || new_member_ids.size < 1
      member_collection = self.hasCollectionMember.dup + new_member_ids

      self.set_value(:hasCollectionMember, member_collection)
      new_member_ids.each do |id|
        new_member = ActiveFedora::Base.find(id)

        # if I'm community and new_member is a collection, update all its members
        if self.is_community?
          new_member.set_value(:belongsToCommunity, [self.id])
          # update children
          if new_member.is_a? Collection
            new_member.materialized_members.each do |child|
              child.set_value(:belongsToCommunity, [self.id])
            end
          end
        else # I'm a collection
          new_member.set_value(:hasCollection, [self.title]) if new_member.respond_to? :hasCollection
          new_member.set_value(:hasCollectionId, [self.id]) if new_member.respond_to? :hasCollectionId
          new_member.set_value(:belongsToCommunity, self.belongsToCommunity) if self.belongsToCommunity?
        end
        new_member.save
      end
    end

    def remove_member_id(id)
      member_collection = self.hasCollectionMember.dup
      member_collection.delete(id)
      self.set_value(:hasCollectionMember, member_collection)
    end

    # from hydra-collections
    # it's questionable if we even need these? -mb
    def update_all_members
      Deprecation.warn(Collection, 'update_all_members is deprecated and will be removed in version 5.0')
      self.materialized_members.collect { |m| update_member(m) }
    end

    # TODO: Use solr atomic updates to accelerate this process
    def update_member(member)
      Deprecation.warn(Collection, 'update_member is deprecated and will be removed in version 5.0')
      member.update_index
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
