class RedirectController < ActionController::Base
  def index
  end

  def item
    begin
      if !is_uuid
        raise "It's not UUID"
      end
      file = find_item
      redirect_to "/files/#{file.id}"
    rescue
      render_404
    end
  end

  def datastream
    begin
      if !is_uuid || !is_datastream
        raise "It's not UUID or DS"
      end
      file = find_item
      redirect_to "/downloads/#{file.id}"
    rescue
      render_404
    end
  end

  def collection
    begin
      if !is_uuid
        raise "It's not UUID"
      end
      file = find_collection
      redirect_to "/collections/#{file.id}"
    rescue
      render_404
    end
  end

  def author
    render_404
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

  def render_404
    render file: "#{Rails.root}/public/404.html", layout: false, status: 404
  end
end
