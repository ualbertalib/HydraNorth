class ApplicationController < ActionController::Base
  # Adds a few additional behaviors into the application controller 
  include Blacklight::Controller
  # Adds Sufia behaviors into the application controller 
  include Sufia::Controller
  # Please be sure to impelement current_user and user_session. Blacklight depends on 
  # these methods in order to perform user specific actions. 

  layout 'sufia-one-column'

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :force_account_link, 
                if: -> { @current_user && @current_user.link_pending? }

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || sufia.dashboard_index_path || root_path
  end

  def force_account_link
    store_location_for @current_user, request.path
    redirect_to link_account_user_path @current_user
  end
end
