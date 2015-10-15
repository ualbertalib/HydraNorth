module Hydranorth
  class SearchBuilder < Hydra::Collections::SearchBuilder
    include Hydranorth::Collections::SearchBehaviors
  end
end
