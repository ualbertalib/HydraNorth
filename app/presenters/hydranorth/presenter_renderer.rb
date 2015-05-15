module Hydranorth
  class PresenterRenderer < Sufia::PresenterRenderer
    include ActionView::Helpers::TranslationHelper
    def display_label(field)
      t(:"#{model_name.param_key}.#{field}_display", scope: label_scope, default: field.to_s.humanize).presence
    end
  end
end
