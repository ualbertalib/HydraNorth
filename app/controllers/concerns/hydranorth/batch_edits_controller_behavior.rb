module Hydranorth
  module BatchEditsControllerBehavior
    extend ActiveSupport::Concern
    include Hydranorth::Breadcrumbs
    include Sufia::BatchEditsControllerBehavior

    def redirect_to_return_controller
      if params[:return_controller]
        redirect_to url_for(controller: params[:return_controller], only_path: true)
      else
        redirect_to sufia.dashboard_index_path
      end
    end

  end
end
