module Hydranorth
  class SerPresenter < GenericFilePresenter
    include Hydra::Presenter
    self.model_class = ::GenericFile
    # Terms is the list of fields displayed by app/views/generic_files/_show_descriptions.html.erb
    self.terms = [:resource_type, :title, :ser, :creator, :contributor, :description, :date_created, :license, :subject, :spatial, :temporal, :is_version_of, :source, :related_url, :language]

  end
end
