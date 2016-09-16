class CollectionsController < ApplicationController
  include Hydranorth::CollectionsControllerBehavior

  # pull in blacklight helpers so that we can use them in our path_for_facet override
  include Blacklight::FacetsHelperBehavior
  include Blacklight::UrlHelperBehavior

  helper_method :path_for_facet, :attach_collection_facet

  # modifies URI 'path' with a facet param limiting the query
  # to the collection 'collection'
  def attach_collection_facet(path, collection)
    uri = URI.parse(path)

    new_params =  URI.decode_www_form(uri.query || '') + [['f[hasCollection_ssim][]', "#{collection.title}"]]
    uri.query = URI.encode_www_form(new_params)
    uri.to_s
  end

  # ovverrides crucial Blacklight method so that we can attach a collection restriction
  def path_for_facet(facet_field, item)
    facet_config = facet_configuration_for_field(facet_field)

    path = if facet_config.url_method
      send(facet_config.url_method, facet_field, item)
    else
      search_action_path(add_facet_params_and_redirect(facet_field, item))
    end

    return attach_collection_facet(path, @collection)
  end
end
