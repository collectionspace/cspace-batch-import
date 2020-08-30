# frozen_string_literal: true

class ConnectionsController < ApplicationController
  before_action :set_connection, only: %i[edit update destroy]
  before_action :check_for_connection_targets_another_user, only: %i[new create]

  def new
    @connection = Connection.new
  end

  def edit; end

  def create
    respond_to do |format|
      @connection = Connection.new
      if @connection.update(permitted_attributes(@connection))
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
      scrub_params(:connection, :password)
      if @connection.update(permitted_attributes(@connection))
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

  def check_for_connection_targets_another_user
    user_id = params.dig(:connection, :user_id) || params[:user_id]
    if user_id.blank? || user_id.to_i != current_user.id
      raise Pundit::NotAuthorizedError
    end
  end

  def set_connection
    @connection = authorize Connection.find(params[:id])
  end
end
