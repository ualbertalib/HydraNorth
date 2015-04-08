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

end
