# frozen_string_literal: true

module Step
  class ProcessesController < ApplicationController
    include Stepable
    before_action :redirect_if_created, only: :new
    before_action :set_batch_state, only: :new
    before_action :set_previous_step_complete, only: :new
    before_action :set_step, only: %i[show reset]

    def new
      @step = Step::Process.new(batch: @batch)
    end

    def create
      respond_to do |format|
        @step = Step::Process.new(batch: @batch)
        if @step.update(process_params)
          format.html do
            @batch.start!
            job = ProcessJob.perform_later(@step)
            @batch.update(job_id: job.provider_job_id)
            redirect_to batch_step_process_path(
              @batch, @batch.step_process
            ), notice: t('action.created', record: 'Process Job')
          end
        else
          format.html do
            @step = Step::Process.new(batch: @batch)
            render :new
          end
        end
      end
    end

    def show; end

    def cancel
      cancel!
      redirect_to batch_step_process_path(
        @batch, @batch.step_process
      ), notice: t('action.step.cancelled')
    end

    def reset
      reset!
      respond_to do |format|
        format.html { redirect_to new_batch_step_process_path(@batch), notice: t('action.step.reset') }
      end
    end

    private

    def process_params
      params.require(:step_process).permit(:check_records, :check_terms)
    end

    def redirect_if_created
      return unless @batch.step_process

      redirect_to batch_step_process_path(
        @batch, @batch.step_process
      )
    end

    def set_batch_state
      @batch.process! unless @batch.processing?
    end

    def set_previous_step_complete
      return if @batch.step_preprocess.done?

      @batch.step_preprocess.update(done: true)
    end

    def set_step
      @step = authorize(@batch).step_process
    end
  end
end
