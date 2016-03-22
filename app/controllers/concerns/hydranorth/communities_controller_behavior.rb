module Hydranorth
  module CommunitiesControllerBehavior
    extend ActiveSupport::Concern
    include Hydra::Catalog
    include Hydranorth::Collections::SelectsCollections

    included do
      before_action only: [:index] do
        find_communities
      end
    end

    def index
    end

    def logo
      @community = Collection.find(params[:id])
      logger.debug @community.logo
      send_data @community.logo.content, disposition: 'inline'
    end

  end
end
