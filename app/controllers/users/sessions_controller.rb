class Users::SessionsController < Devise::SessionsController
  
  # override default session creation logic in order to
  # enforce CCID rules on users who have associated with a CCID
  def create
    return super unless @current_user && !@current_user.can_use_legacy_login?
    flash[:error] = I18n.t('unauthorized.ccid_required')
    sign_out @current_user
    redirect_to :new_user_session
  end
end