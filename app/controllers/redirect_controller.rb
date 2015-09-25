class RedirectController < ActionController::Base
  include Blacklight::SolrHelper
  
  attr_reader :id 
  
  def item
    
    # search item by uuid (fedora3uuid_tesim)
    @id = find_item_id
    logger.debug "logger id: #{@id} "
    
    # redirect to hydranorth item
    redirect_to "/files/9880vq965"
    
  end
  
  def datastream

    # construct hydranorth datastream url 
    
    
    # redirect to the url
    redirect_to "/downloads/9880vq965"
    
  end
  
  private
  
  def find_item_id
    uuid = params[:uuid]
    logger.debug "uuid: #{uuid}"
    solr_params = "q=fedora3uuid:" + uuid
    (@response, @member_docs) = get_search_results(solr_params)
    @id = "9880vq965"
  end
  
end