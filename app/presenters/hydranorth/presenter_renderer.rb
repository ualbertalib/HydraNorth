module Hydranorth
  class PresenterRenderer < Sufia::PresenterRenderer
    include ActionView::Helpers::TranslationHelper

    def initialize(presenter, view_context)
      presenter.render_context = view_context
      super
    end

    def display_label(field)
      t(:"#{model_name.param_key}.#{field}_display", scope: label_scope, default: field.to_s.humanize).presence
    end
  end
end
