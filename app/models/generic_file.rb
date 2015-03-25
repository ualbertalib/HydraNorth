class GenericFile < ActiveFedora::Base
  include Sufia::GenericFile
  include Hydra::AccessControls::Embargoable
  include Hydra::AccessControls::WithAccessRight
  include Hydranorth::GenericFile::Metadata
  include Hydranorth::GenericFile::Export
end
