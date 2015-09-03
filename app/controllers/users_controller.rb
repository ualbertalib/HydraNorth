class UsersController < ApplicationController
  include Hydranorth::UsersControllerBehavior

  skip_before_filter :force_account_link, only: [:link_account, :set_saml]

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
 
  def link_account; end

  def set_saml
    if params[:has_account] == 'yes'
      existing_user = User.find_by_email(params[:user][:email]) if params[:user][:email].present?

      # the user may have typoed the email they tried to link
      # fake success to satisfy OWASP
      if existing_user.nil?
        pending = true
      end
    else
      # if we're here, they've indicated they have no existing account
      # we treat this as a special case of the general linking
      existing_user = @user
    end
    pending ||= existing_user.link!(@user)

    if pending
      flash[:notice] = I18n.t('devise.confirmations.send_paranoid_instructions', :kind => 'Shibboleth')
      sign_out @user
      # delete the extraneous CCID account
      @user.destroy
    else
      flash[:notice] = I18n.t('devise.omniauth_callbacks.success', :kind => 'Shibboleth')
      sign_in_and_redirect @user, :event => :authentication
    end
  end

end
