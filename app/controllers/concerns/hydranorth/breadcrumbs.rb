  module Hydranorth
  module Breadcrumbs
    extend ActiveSupport::Concern
    include Sufia::Breadcrumbs

    def trail_from_referer
      case request.referer
      when /catalog/
        add_breadcrumb I18n.t('sufia.bread_crumb.search_results'), request.referer
      when /all/
        default_trail
        add_breadcrumb I18n.t('hydranorth.dashboard.my.all'), request.referer
      else
        default_trail
        add_breadcrumb_for_controller
        add_breadcrumb_for_action
      end
    end

  end
end
