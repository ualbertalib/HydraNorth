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
        link_to download_image_tag, download_path(@generic_file), { target: '_blank', rel: 'noopener noreferrer', title: "Download the document", id: "file_download", data: { label: @generic_file.id } }
      else
        link_to (download_image_tag(title) + title), download_path(@generic_file), { target: '_blank', rel: 'noopener noreferrer', title: title, id: "file_download", data: { label: @generic_file.id } }
      end
    end
  end

  # if passed a block, this method conditionally renders the markup in the block only if the path is present. This
  # provides an easy way of sanely dealing with some items having files (and thus download paths) and others not.
  def render_download_link(item, text = nil)
    # in Communities, Collections appear in lists alongside files, and so they are rendered through the same partial
    # but collections have no download link
    path = download_path(item)
    return '' unless path.present?

    download_link = link_to (text || 'Download'), path, { id: 'file_download', target: '_blank', rel: 'noopener noreferrer', data: { label: item.id } }
    yield download_link if block_given?
    return download_link
  end

  def download_url(*args)
    path = download_path(*args)
    return "#{request.protocol}#{request.host}#{path}"
  end

  # sufia.download path is from Sufia::Engine.routes.url_helpers
  # download_path is currently called in the following ways in Sufia and HydraNorth
  # download_path(@generic_file)
  # download_path(id)
  # download_path(@generic_file, file: 'webm')
  # download_path(id: @asset)
  # download_path document, file: 'thumbnail'
  #
  # we shouldn't be overloading this to accept everything under the sun (GenericFiles, SolrDocs, Strings,
  # Collections...) as it has lead to all manner of bugs and corner cases, but these usages are imposed by Hydra/Sufia,
  # so we're forced to live with it.
  #
  # The precondition here is that if you're calling this, you're only going to get a sensible result on objects that
  # actually have files. Not every object does, and there are various valid cases in which an object won't have one
  # (Weiwei mentions that both dataverse objects and migrated items from Thesis deposit may not).
  #
  # Nil is returned for objects without files, to push decisions on how to sanely handle objects with no files up
  # to the calling context. You probably want to use render_download_link or a different client function to generate
  # the link for you -- it can cleanly not render the surrounding markup at all if this returns nil.
  def download_path(*args)
    raise ArgumentError unless args.present?

    item = item_for_download(args.shift)
    return nil unless item.present? && (item.label.present? || item.filename.present? || item.doi_url.present?)

    # doi supercedes anything else
    return item.doi_url if item.doi_url.present?

    # otherwise path is /files/noid/(label or filename)
    path = "/files/#{item.id}/" + (item.label.nil? ? URI::encode(item.filename.first) : URI::encode(item.label))

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

  # this could be a string (item ID), a SolrDocument corresponding to the cache of a GenericFile, a fully reified
  # GenericFile itself, or a Collection which isn't downloadable but which is rendered through the same partials. (
  # All of these are usages of download_path imposed on us by Sufia, unfortunately, so this can't
  # be easily rationalized. Ideally, SolrDocuments are preferable to GenericFiles for performance reasons, so we try
  # to minimize reification of IDs whenever possible.
  def item_for_download(candidate)
    candidate = candidate.model if candidate.is_a?(Hydranorth::GenericFilePresenter)
    return nil if candidate.is_a?(Collection)
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
