class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def shibboleth
    auth = request.env['omniauth.auth']
    unless @current_user.present?
      @user = User.from_omniauth(auth).first
      @user.associate_auth(auth) if @user && @user.ccid.nil?
      @user ||= User.create_from_omniauth(auth)
    else
      @user = @current_user
      @user.associate_auth(auth)
    end
    flash[:notice] = I18n.t('devise.omniauth_callbacks.success', :kind => 'Shibboleth')
    sign_in_and_redirect @user, :event => :authentication
  end
end
