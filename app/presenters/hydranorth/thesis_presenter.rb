module Hydranorth
  class ThesisPresenter < GenericFilePresenter
    include Hydra::Presenter
    self.model_class = ::GenericFile
    # Terms is the list of fields displayed by app/views/generic_files/_show_descriptions.html.erb
    self.terms = [:title, :alternative_title, :subject, :resource_type, :degree_grantor, :dissertant, :supervisor, :committee_member, :department, :specialization, :date_submitted, :date_accepted, :graduation_date, :thesis_name, :thesis_level, :abstract, :language, :rights, :is_version_of]

  end
end
