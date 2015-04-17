module Hydranorth
  module CollectionsControllerBehavior
    extend ActiveSupport::Concern
    include Sufia::CollectionsControllerBehavior

    def show
      if current_user && current_user.admin?
        self.search_params_logic -= [:add_access_controls_to_solr_params]
      end
    
      super
      presenter
    end

    protected

    def presenter_class
      Hydranorth::CollectionPresenter
    end

    def collection_params
      params.require(:collection).permit(:title, :description, :license, :members, part_of: [],
        creator: [], date_created: [], subject: [],
        rights: [], resource_type: [], identifier: [])
       
    end

    def form_class
      Hydranorth::Forms::CollectionEditForm
    end

  end
end
