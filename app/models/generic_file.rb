class GenericFile < ActiveFedora::Base
  include Sufia::GenericFile
  include Hydra::AccessControls::Embargoable
  include Hydra::AccessControls::WithAccessRight
end
