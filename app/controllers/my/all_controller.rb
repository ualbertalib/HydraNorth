module My
  class AllController < MyController

    def index
      self.search_params_logic += [
        :show_only_generic_files
      ]  
      super

      @selected_tab = :all
    end

    protected

    def search_action_url *args
      sufia.dashboard_shares_url *args
    end

  end
end
