# frozen_string_literal: true

class BatchesController < ApplicationController
  before_action :set_batch, only: %i[destroy]

  def index
    @batches = policy_scope(Batch).order(:created_at)
  end

  def new
    @batch = Batch.new
  end

  def create; end

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
