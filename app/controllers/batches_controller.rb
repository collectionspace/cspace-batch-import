# frozen_string_literal: true

class BatchesController < ApplicationController
  before_action :set_batch, only: %i[destroy]
  # before_action :check_for_batch_targets_another_group, only: %i[create]

  def index
    @batches = policy_scope(Batch).order('created_at DESC')
  end

  def new
    authorize(Batch)
    @batch = Batch.new
    @connection ||= current_user.default_connection
  end

  def create
    respond_to do |format|
      @batch = Batch.new
      group_id = params.dig(:batch, :group_id) ? params[:batch][:group_id] : current_user.group.id
      if @batch.update(
        permitted_attributes(@batch).merge(user_id: current_user.id, group_id: group_id)
      )
        format.html do
          redirect_to new_batch_step_preprocess_path(@batch), notice: t('batch.created')
        end
      else
        @batch = Batch.new
        @connection ||= current_user.default_connection
        format.html { render :new }
      end
    end
  end

  def destroy
    @batch.destroy
    respond_to do |format|
      format.html { redirect_to batches_path, notice: t('batch.deleted') }
    end
  end

  private

  def set_batch
    @batch = authorize Batch.find(params[:id])
  end
end
