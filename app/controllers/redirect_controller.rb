class RedirectController < ActionController::Base
  
  def item
    
    # search item by uuid
    
    # redirect to hydranorth item
    redirect_to '/collections/hq37vn58w'
    
  end
  
  def datastream
    
    # construct hydranorth datastream url 
    
    # redirect to the url
    redirect_to '/collections/hq37vn595'
    
  end
  
end