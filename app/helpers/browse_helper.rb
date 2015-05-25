module BrowseHelper

	include Blacklight::Facet
   
 def has_browse_values? fields = facet_field_names, options = {}
    facets_from_request(fields).any? { |display_facet| !display_facet.items.empty? }
  end

   def render_browse_value(facet_field, item, options ={})
    path = search_action_path(add_facet_params_and_redirect(facet_field, item))
    content_tag(:span, :class => "facet-label") do
      link_to_unless(options[:suppress_link], facet_display_value(facet_field, item), path, :class=>"facet_select")
    end + render_facet_count(item.hits)
  end
end
