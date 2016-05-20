module ApplicationHelper
  include ::LinkUtils

  def render_facet_path(collection)
    path = "?f[hasCollectionId_ssim=#{collection}"  
  end

  def render_checked_constraints(localized_params = params)
    if localized_params[:f] and localized_params[:f][:hasCollectionId_ssim]
      localized_params.tap{|d| d[:f].tap{|h| h.delete("hasCollectionId_ssim")}}
    end
    render_constraints_query(localized_params) + render_constraints_filters(localized_params)
  end

  def visibility_options(variant)
    options = [
        ['Open Access', Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC],
        ['Authenticated Access', Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED],
        [t('sufia.institution_name'), Hydranorth::AccessControls::InstitutionalVisibility::UNIVERSITY_OF_ALBERTA],
        ['Private', Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE]
    ]
    case variant
      when :restrict
        options.delete_at(0)
        options.reverse!
      when :loosen
        options.delete_at(3)
    end
    return options
  end

  def visibility_badge(value)
    case value
      when Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
        content_tag :span, "Open Access", class:"label label-success"
      when Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED
        content_tag :span, 'Authenticated Access', class:"label label-info"
      when Hydranorth::AccessControls::InstitutionalVisibility::UNIVERSITY_OF_ALBERTA
        content_tag :span, t('sufia.institution_name'), class:"label label-info"
      when Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
        content_tag :span, "Private", class:"label label-danger"
      when Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_EMBARGO
        content_tag :span, "Embargo", class:"label label-warning"
      when Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_LEASE
        content_tag :span, "Lease", class:"label label-warning"
      else
        content_tag :span, value, class:"label label-info"
    end
  end

end
