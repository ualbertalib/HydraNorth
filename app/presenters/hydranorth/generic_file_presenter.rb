class Hydranorth::GenericFilePresenter < Hydranorth::Presenter
  self.model_class = ::GenericFile
  # Terms is the list of fields displayed by app/views/generic_files/_show_descriptions.html.erb
  self.terms = [:title, :creator, :contributor, :subject, :resource_type, :language, :spatial, :temporal, :description, :date_created, :license, :rights, :is_version_of, :source, :related_url, :belongsToCommunity, :hasCollectionId, :ark_id]

  # Depositor and permissions are not displayed in app/views/generic_files/_show_descriptions.html.erb
  # so don't include them in `terms'.
  delegate :depositor, :permissions, to: :model

  def tweeter
    user = ::User.find_by_user_key(model.depositor)
    if user.try(:twitter_handle).present?
      "@#{user.twitter_handle}"
    else
      I18n.translate('sufia.product_twitter_handle')
    end
  end

  # Add a schema.org itemtype
  def itemtype
    # Look up the first non-empty resource type value in a hash from the config
    Sufia.config.resource_types_to_schema[resource_type.to_a.reject { |type| type.empty? }.first] || 'http://schema.org/CreativeWork'
  rescue
    'http://schema.org/CreativeWork'
  end
end
