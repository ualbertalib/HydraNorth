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

end
