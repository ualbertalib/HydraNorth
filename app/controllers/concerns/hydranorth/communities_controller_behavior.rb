module Hydranorth
  module CommunitiesControllerBehavior
    extend ActiveSupport::Concern
    include Hydra::Catalog
    include Hydranorth::Collections::CollectionSelection
    include Hydranorth::Collections::CommunitySelection

    def index
      @user_communities = find_communities
      @user_collections, @grouped_user_collections = find_collections_grouped_by_community
    end

    def logo
      @community = Collection.find(params[:id])
      send_data @community.logo.content, disposition: 'inline'
    end

  end
end
