module Hydranorth
  module GenericFile
    extend ActiveSupport::Concern
    include Sufia::GenericFile
    include Hydranorth::ModelMethods
  end
end
