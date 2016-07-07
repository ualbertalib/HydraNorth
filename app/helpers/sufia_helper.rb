module SufiaHelper
  include ::BlacklightHelper
  include Sufia::BlacklightOverride
  include Sufia::SufiaHelperBehavior

  # override SufiaHelperBehavior method for institutional_access? condition
  def sufia_thumbnail_tag(document, options)
    # collection
    if document.collection?
      content_tag(:span, "", class: "glyphicon glyphicon-th collection-icon-search")

    # file
    else
      path =
        if cannot?(:download, document)
          "default.png"
        elsif document.image? || document.pdf? || document.video? || document.office_document?
          sufia.download_path document, file: 'thumbnail'
        elsif document.audio?
          "audio.png"
        else
          "default.png"
        end
      options[:alt] = ""
      image_tag path, options
    end
  end 
end
