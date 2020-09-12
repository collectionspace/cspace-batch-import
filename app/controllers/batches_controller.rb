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
        if spreadsheet_ok?
          format.html do
            redirect_to new_batch_step_preprocess_path(@batch), notice: t('batch.created')
          end
        else
          format.html { return redirect_to new_batch_path }
        end
      else
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

  def spreadsheet_ok?
    continue = false
    Batch.validator_for(@batch) do |validator|
      if validator.valid?
        @batch.update(num_rows: validator.row_count)
        continue = true
      else
        @batch.destroy # scrap it, they'll have to start over
        flash[:csv_lint] = validator.errors.take(5)
      end
    end

    continue
  end

  def set_batch
    @batch = authorize Batch.find(params[:id])
  end
end
