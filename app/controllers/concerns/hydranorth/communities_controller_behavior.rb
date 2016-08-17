module Hydranorth
  module CommunitiesControllerBehavior
    extend ActiveSupport::Concern
    include Hydra::Catalog
    include Hydranorth::Collections::CollectionSelection
    include Hydranorth::Collections::CommunitySelection

    def index
      @user_communities = find_communities

      # TODO we should move this into the query itself, but that can't happen until after the re-index of communities &
      # collections populates sortable_title_ssi
      @user_communities.sort! do |a,b|
        a.title.downcase <=> b.title.downcase
      end

      @user_collections, @grouped_user_collections = find_collections_grouped_by_community
    end

    def logo
      @community = Collection.find(params[:id])
      send_data @community.logo.content, disposition: 'inline'
    end

  end
end
