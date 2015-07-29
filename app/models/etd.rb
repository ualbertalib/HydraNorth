class ETD < ActiveFedora::Base
  include Sufia::GenericFile
  include Hydranorth::Etd::Metadata
  include Hydra::AccessControls::Embargoable
  include Hydra::AccessControls::WithAccessRight
  include Hydranorth::GenericFile::Export
  include Hydranorth::GenericFile::Fedora3Foxml

end
