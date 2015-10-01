class RedirectController < ApplicationController
  def item
    return render_404 ActiveRecord::RecordNotFound unless is_uuid
    file = find_item
    redirect_to "/files/#{file.id}", status: :moved_permanently
  end

  def datastream
    return render_404 ActiveRecord::RecordNotFound unless is_uuid && is_datastream
    file = find_item
    redirect_to "/downloads/#{file.id}", status: :moved_permanently
  end

  def collection
    return render_404 ActiveRecord::RecordNotFound unless is_uuid
    file = find_collection
    redirect_to "/collections/#{file.id}", status: :moved_permanently
  end

  def author
    render_410
  end

  def thesis
    return render_404 ActiveRecord::RecordNotFound unless params[:uuid] == "uuid:7af76c0f-61d6-4ebc-a2aa-79c125480269"
    redirect_to "https://thesisdeposit.library.ualberta.ca/action/submit/init/thesis/uuid:7af76c0f-61d6-4ebc-a2aa-79c125480269"
  end

  private

  def is_uuid
    return (/^uuid:.+/ =~ params[:uuid]) != nil
  end

  def is_datastream
    return (/^DS\d+/ =~ params[:ds]) != nil
  end

  def find_item
    uuid = params[:uuid].split(":")[1]
    file = GenericFile.find(fedora3uuid: uuid).first
  end

  def find_collection
    if !params[:uuid].start_with?("uuid:")
      return nil
    end
    uuid = params[:uuid].split(":")[1]
    file = Collection.find(fedora3uuid: uuid).first
  end

  def render_410
    render template: '/error/404', layout: "error", formats: [:html], status: :gone
  end

end
