class Admin::BecomeController < ApplicationController
  before_filter :authenticate_user!

  def index
    if params[:id].nil? || User.find_by_email(params[:id]).nil?
      flash[:alert] = I18n.t('error.become_user')
    elsif current_user.admin?
      sign_out current_user
      sign_in(:user, User.find_by_email(params[:id]))
    else
      flash[:alert] = I18n.t('unauthorized.become_user')
    end
    redirect_to root_url # or user_root_url
  end
end
