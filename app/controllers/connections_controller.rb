# frozen_string_literal: true

class ConnectionsController < ApplicationController
  before_action :set_connection, only: %i[edit update destroy]

  def new
    @connection = Connection.new
  end

  def edit; end

  def create
    @connection = Connection.new(connection_params)

    respond_to do |format|
      if @connection.save
        format.html { redirect_to @connection, notice: t('connection.created') }
      else
        format.html { render :new }
      end
    end
  end

  def update
    respond_to do |format|
      if @connection.update(connection_params)
        format.html { redirect_to @connection, notice: t('connection.updated') }
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

  def set_connection
    @connection = authorize Connection.find(params[:id])
  end

  def connection_params
    params.require(:connection).permit(policy(@connection).permitted_attributes)
  end
end
