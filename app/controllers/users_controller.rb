class UsersController < ApplicationController
  include Hydranorth::UsersControllerBehavior

  def edit
    @user = User.from_url_component(params[:id])
    @trophies = @user.trophy_files
  end

  def user_is_current_user
    redirect_to sufia.profile_path(@user.to_param), alert: "Permission denied: cannot access this page." unless @user == current_user || current_user.admin?
  end

  def lock_access
    @user.lock_access! unless ! current_user.admin?
    redirect_to sufia.profile_path(@user.to_param)
  end

  def unlock_access
    @user.unlock_access! unless ! current_user.admin?
    redirect_to sufia.profile_path(@user.to_param)
  end
 
  def link_account
  end

  def set_saml
    if (params[:has_account] == 'no') || params[:user][:email].nil?
      @user.ccid = @user.email
      flash[:notice] = I18n.t('devise.omniauth_callbacks.success', :kind => 'Shibboleth')
      sign_in_and_redirect @user, :event => :authentication
    else
      @account = User.find_by_email(params[:user][:email])
      @account.update_attribute(:ccid, @user.email) unless @account.nil?
      flash[:notice] = I18n.t('devise.confirmations.send_paranoid_instructions', :kind => 'Shibboleth')
      sign_out @user
    end
  end

end
