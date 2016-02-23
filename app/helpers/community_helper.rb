module CommunityHelper
  def collections_in_community(community_id)
    collections = Collection.find(community_id).members.to_a
  end
  def count_collections_in_community(community_id)
    return Collection.find(community_id).member_count
  end
end
