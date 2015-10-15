class SearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  include Hydra::AccessControlsEnforcement
  include Sufia::SearchBuilder

   def include_collection_ids(solr_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << "(active_fedora_model_ssi:Collection AND belongsToCommunity_tesim:#{collection.id}) OR hasCollectionId_ssim:#{collection.id}"
  end
end
