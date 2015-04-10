class Collection < Sufia::Collection
  include Hydranorth::Collections::Metadata
  include Hydra::Collections::Collectible
  include Hydra::Collection

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

  def file_size
    [] 
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

end
