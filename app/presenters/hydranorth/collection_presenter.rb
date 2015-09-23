class Hydranorth::CollectionPresenter < Hydranorth::Presenter
  include ActionView::Helpers::NumberHelper

  self.model_class = ::Collection
  # Terms is the list of fields displayed by app/views/collections/_show_descriptions.html.erb
  #temporarily remove size from the view to reduce loading time

  self.terms = [:title, :total_items, :description, :creator,
                :date_created]

  # Depositor and permissions are not displayed in app/views/collections/_show_descriptions.html.erb
  # so don't include them in `terms'.
  # delegate :depositor, :permissions, to: :model

  def terms_with_values
    terms.select { |t| self[t].present? }
  end

  def [](key)
    case key
      when :size
        size
      when :total_items
        total_items
      else
        super
    end
  end

  def size
    number_to_human_size(model.bytes)
  end

  # total item count is determined by taking the count of all items in the
  # collection that are readable in the current context eg) which the viewing
  # user's abilities allow them to read
  def total_items
    model.members.select do |item|
      render_context.can? :read, item
    end.count
  end

end
