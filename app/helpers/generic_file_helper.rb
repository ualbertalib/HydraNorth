# -*- coding: utf-8 -*-
module GenericFileHelper
  def display_title(gf)
    gf.to_s
  end

  def present_terms(presenter, terms=:all, &block)
    terms = presenter.terms if terms == :all
    Hydranorth::PresenterRenderer.new(presenter, self).fields(terms, &block)
  end

  def render_download_icon title = nil
    if title.nil?
      link_to download_image_tag, download_path(@generic_file), { target: "_blank", title: "Download the document", id: "file_download", data: { label: @generic_file.id } }
    else
      link_to (download_image_tag(title) + title), download_path(@generic_file), { target: "_blank", title: title, id: "file_download", data: { label: @generic_file.id } }
    end
  end

  def render_download_link text = nil
    link_to (text || "Download"), download_path(@generic_file), { id: "file_download", target: "_new", data: { label: @generic_file.id } }
  end

  # sufia.download path is from Sufia::Engine.routes.url_helpers
  # download_path is currently called in the following ways in Sufia and HydraNorth
  # download_path(@generic_file)
  # download_path(id)
  # download_path(@generic_file, file: 'webm')
  # download_path(id: @asset)
  # download_path document, file: 'thumbnail'
  def download_path(*args)
    gf = args.first if args.first.is_a? GenericFile
    gf ||= GenericFile.find(args.first.id) if args.first.is_a? SolrDocument
    gf && gf.doi_url.present? ? gf.doi_url : sufia.download_path(*args)
  end

  def render_collection_list(gf)
    nested_collection = ''

    nested_collection ||= if (gf.respond_to?(:hasCollection) && gf.hasCollectionId.present?)
      'Is part of: ' + link_to(title, collections.collection_path(gf.hasCollectionId.first))
    elsif gf.respond_to?(:belongsToCommunity) && gf.belongsToCommunity.present?
      # This is EXTREMELY expensive, and it would be nice if items cached the name of their Community analogous to the way they do
      # with Collection names in hasCollection
      'Is part of: ' + link_to(Collection.find(id).title, collections.collection_path(gf.belongsToCommunity.first))
    end

    return nested_collection.html_safe
  end

  def display_multiple(value)
    auto_link(value.join(" | "))
  end

  private

  def download_image_tag(title = nil)
    if title.nil?
      image_tag "default.png", { alt: "No preview available", class: "img-responsive" }
    else
      image_tag download_path(@generic_file, file: 'thumbnail'), { class: "img-responsive", alt: "#{title} of #{@generic_file.title.first}" }
    end
  end

  def render_visibility_badge
    if can? :edit, @generic_file
      render_visibility_link @generic_file
    else
      render_visibility_label @generic_file
    end
  end

end
