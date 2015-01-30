class UsersController < ApplicationController
  include Hydranorth::UsersControllerBehavior

  def user_is_current_user
    redirect_to sufia.profile_path(@user.to_param), alert: "Permission denied: cannot access this page." unless @user == current_user || current_user.admin?
  end
end
