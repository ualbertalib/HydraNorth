class RedirectController < ApplicationController
  def item
    return render_404 ActiveRecord::RecordNotFound unless is_uuid
    file = find_item_id
    return render_404 ActiveRecord::RecordNotFound if file.nil?
    redirect_to "/files/#{file}", status: :moved_permanently
  end

  def datastream
    return render_404 ActiveRecord::RecordNotFound unless is_uuid && is_datastream
    file = find_item_id
    return render_404 ActiveRecord::RecordNotFound if file.nil?
    redirect_to "/downloads/#{file}", status: :moved_permanently
  end

  def collection
    return render_404 ActiveRecord::RecordNotFound unless is_uuid
    file = find_collection_id
    return render_404 ActiveRecord::RecordNotFound if file.nil?
    redirect_to "/collections/#{file}", status: :moved_permanently
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

  def find_item_id
    uuid = params[:uuid]
    id = find_id(uuid)
  end

  def find_collection_id
    uuid = params[:uuid]
    id = find_id(uuid)
  end

  def render_410
    render template: '/error/404', layout: "error", formats: [:html], status: :gone
  end

  def find_id(uuid)
    solr_rsp =  ActiveFedora::SolrService.instance.conn.get 'select', :params => {:q => Solrizer.solr_name('fedora3uuid')+':'+uuid}
    numFound = solr_rsp['response']['numFound']
    if numFound > 0
      return solr_rsp['response']['docs'].first['id']
    else
      return nil
    end
  end

end
