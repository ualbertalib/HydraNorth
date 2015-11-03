class GenericFile < ActiveFedora::Base
  include Sufia::GenericFile
  include Hydranorth::AccessControls::InstitutionalVisibility
  include Hydranorth::GenericFile::Metadata
  include Hydranorth::Thesis::Metadata
  include Hydranorth::GenericFile::Export
  include Hydranorth::GenericFile::Fedora3Foxml
  include Hydranorth::GenericFile::DOI
  include Hydranorth::GenericFile::GaStats

end
