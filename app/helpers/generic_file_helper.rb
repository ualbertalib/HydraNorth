# -*- coding: utf-8 -*-
module GenericFileHelper

  def display_title(gf)
    gf.to_s
  end

  def present_terms(presenter, terms=:all, &block)
    terms = presenter.terms if terms == :all
    Hydranorth::PresenterRenderer.new(presenter, self).fields(terms, &block)
  end

  def render_download_icon(title = nil)
    if @generic_file.label.present? || @generic_file.doi_url.present? || !@generic_file.filename.empty?
      if title.nil?
        link_to download_image_tag, download_path(@generic_file), { target: "_blank", title: "Download the document", id: "file_download", data: { label: @generic_file.id } }
      else
        link_to (download_image_tag(title) + title), download_path(@generic_file), { target: "_blank", title: title, id: "file_download", data: { label: @generic_file.id } }
      end
    end
  end

  def render_download_link(text = nil)
    if @generic_file.label.present? || !@generic_file.filename.empty?
      link_to (text || "Download"), download_path(@generic_file), { id: "file_download", target: "_new", data: { label: @generic_file.id } }
    end
  end

  # sufia.download path is from Sufia::Engine.routes.url_helpers
  # download_path is currently called in the following ways in Sufia and HydraNorth
  # download_path(@generic_file)
  # download_path(id)
  # download_path(@generic_file, file: 'webm')
  # download_path(id: @asset)
  # download_path document, file: 'thumbnail'
  #
  # we shouldn't be overloading this to accept everything under the sun as it leads to all
  # manner of bugs and corner cases, but these usages are imposed by Hydra/Sufia, so we're forced to live with
  # it
  def download_path(*args)
    raise ArgumentError unless args.present?
    item = item_for_download(args.shift)

    # doi supercedes anything else
    return item.doi_url if item.doi_url.present?

    # this shouldn't happen normally in production, because it indicates an item with no file
    # but a BUNCH of our tests do create items like this
    unless item.label.present? || item.filename.present?
      logger.error "item with no file found! id: #{item.id}"
      # this would be a good place for hoptoad/airbrake/newrelic-style alerting
      return "/files/#{item.id}/"
    end

    # otherwise path is /files/noid/(label or filename)
    path = "/files/#{item.id}/" + (item.label.nil? ? URI::encode(item.filename) : URI::encode(item.label))

    # appeand query args to download path, eg. /files/noid/label?file=thumbnail or file=mp3, etc
    unless args.empty?
      path += Hydranorth::RawFedora::stringify_args(args.shift)
    end

    return path
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

  # this could be a string (item ID), a SolrDocument corresponding to the cache of a GenericFile, or a fully reified
  # GenericFile itself (all of these are usages of download_path imposed on us by Sufia, unfortunately, so this can't
  # be easily rationalized). Ideally, SolrDocuments are preferable to GenericFiles for performance reasons, so we try
  # to minimize reification of IDs whenever possible.
  def item_for_download(candidate)
    return candidate if candidate.is_a?(SolrDocument) || candidate.is_a?(GenericFile)

    # TODO could we fish this out of Solr and send back a SolrDocument instead?
    # it would be much faster
    return GenericFile.find(candidate) if candidate.is_a?(String)
    raise ArgumentError
  end

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
