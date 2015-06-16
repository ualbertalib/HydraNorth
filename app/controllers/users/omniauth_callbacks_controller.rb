class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def shibboleth 
    @user = User.from_omniauth(request.env["omniauth.auth"])
    if @user.persisted?
      flash[:notice] = I18n.t('devise.omniauth_callbacks.success', :kind => 'Shibboleth')
      sign_in_and_redirect @user, :event => :authentication
    else
      session['devise.shibboleth_data'] = env['omniauth.auth']
      redirect_to new_user_registration_url
    end
  end
end
