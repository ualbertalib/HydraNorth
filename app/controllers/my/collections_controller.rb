module My
  class CollectionsController < MyController
    warn "[DEPRECATION] `CollectionsController` will be fixed in Sufia 6.0.1 and can be removed from HydraNorth"

    self.search_params_logic += [
      :show_only_files_deposited_by_current_user,
      :show_only_collections
    ]

    def index
      super
      @selected_tab = :collections
    end

    protected

    def search_action_url *args
      sufia.dashboard_collections_url *args
    end
  end
end
