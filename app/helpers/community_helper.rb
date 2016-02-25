module CommunityHelper
  def collections_in_community(community_id)
    query = {
        fq: "(-hasCollectionId_ssim:[* TO *] AND (belongsToCommunity_ssim:#{community_id} OR belongsToCommunity_tesim:#{community_id})) OR hasCollectionId_ssim:#{community_id}",
        rows: 1000
      }

    response = Blacklight.default_index.search(query)
    response.documents
  end
  def count_collections_in_community(community_id)
    return Collection.find(community_id).member_count
  end
end
