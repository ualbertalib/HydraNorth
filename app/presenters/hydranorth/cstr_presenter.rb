class Hydranorth::CstrPresenter < Hydranorth::GenericFilePresenter
  # Terms is the list of fields displayed by app/views/generic_files/_show_descriptions.html.erb
  self.terms = [:title, :creator, :contributor, :subject, :resource_type, :trid, :language, :spatial, :temporal, :description, :date_created, :doi, :license, :rights, :is_version_of, :source, :related_url, :belongsToCommunity, :hasCollectionId]
end
