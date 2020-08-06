# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user, only: %i[edit update destroy]

  def index
    authorize(User)
    @users = policy_scope(User).includes(:group, :role).order('groups.name asc, users.email asc')
  end

  def edit; end

  def update
    respond_to do |format|
      if @user.update(user_params)
        reset_user(@user)
        format.html { redirect_to edit_user_path(@user), notice: t('user.updated') }
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: t('user.deleted') }
    end
  end

  # Become user functionality
  def impersonate
    user = authorize User.find(params[:id])
    impersonate_user(user)
    redirect_back fallback_location: root_path
  end

  def stop_impersonating
    stop_impersonating_user
    redirect_back fallback_location: root_path
  end

  private

  def reset_user(user)
    current_user.is?(user) ? bypass_sign_in(user) : bypass_sign_in(current_user)
  end

  def set_user
    @user = authorize User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(policy(@user).permitted_attributes)
  end
end
