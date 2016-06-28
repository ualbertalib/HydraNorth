module My
  class FilesController < MyController

    self.search_params_logic += [
      :show_only_files_with_access,
      :show_only_generic_files
    ]

    def index
      super
      @selected_tab = :files
      @selected_tab_path = sufia.dashboard_files_path
    end

    protected

    def search_action_url *args
      sufia.dashboard_files_url *args
    end

  end
end
