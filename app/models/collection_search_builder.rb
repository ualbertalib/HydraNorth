class CollectionSearchBuilder < Hydra::Collections::SearchBuilder
  # raise the default limit on solr results so that we don't
  # truncate the number of returned collections accidently
  def some_rows(solr_parameters)
    solr_parameters[:rows] = '1000'
  end
end
