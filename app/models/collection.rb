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

  def processing?
    false
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
