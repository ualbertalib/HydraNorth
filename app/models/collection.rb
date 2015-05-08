class Collection < Sufia::Collection
  include Hydranorth::Collections::Metadata
  include Hydranorth::Collections::Fedora3Foxml
  include Hydra::Collections::Collectible
  include Hydra::Collection
  has_and_belongs_to_many :members, predicate:  ActiveFedora::RDF::Fcrepo::RelsExt.hasCollectionMember, class_name: "ActiveFedora::Base" , after_remove: :update_member, solr_page_size:70
  before_save :remove_self_from_members

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
 
  # Compute the sum of each file in the collection
  # Don't count anything that is not a file
  # Return an integer of the result
  def bytes
    members.reduce(0) do |sum, gf| 
      gf.respond_to?(:content) ? sum + gf.content.size.to_i : sum
    end
  end

end
