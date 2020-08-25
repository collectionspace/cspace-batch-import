# frozen_string_literal: true

class ConnectionsController < ApplicationController
  before_action :set_connection, only: %i[edit update destroy]

  def new
    check_for_connection_targets_another_user(params[:user_id])
    @connection = Connection.new
  end

  def edit; end

  def create
    respond_to do |format|
      @connection = Connection.new
      check_for_connection_targets_another_user(connection_params[:user_id])
      if @connection.update(connection_params)
        format.html do
          redirect_to edit_user_path(current_user),
                      notice: t('connection.created')
        end
      else
        format.html { render :new }
      end
    end
  end

  def update
    respond_to do |format|
      if @connection.update(connection_params)
        format.html do
          redirect_to edit_connection_path(@connection), notice: t('connection.updated')
        end
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    user = @connection.user
    @connection.destroy
    respond_to do |format|
      format.html { redirect_to edit_user_path(user), notice: t('connection.deleted') }
    end
  end

  private

  def check_for_connection_targets_another_user(user_id)
    raise Pundit::NotAuthorizedError if user_id.blank? || user_id.to_i != current_user.id
  end

  def set_connection
    @connection = authorize Connection.find(params[:id])
  end

  def connection_params
    params.require(:connection).permit(policy(@connection).permitted_attributes)
  end
end
