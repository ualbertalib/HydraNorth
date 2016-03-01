module Hydranorth
  module CommunitiesControllerBehavior
    extend ActiveSupport::Concern
    include Hydra::Catalog
    include Hydranorth::Collections::SelectsCollections

    included do
      before_action only: [:index] do
        find_communities
        find_collections_grouped_by_community
      end
    end

    def index
    end
  end
end
