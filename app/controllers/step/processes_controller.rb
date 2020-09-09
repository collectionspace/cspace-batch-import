# frozen_string_literal: true

module Step
  class ProcessesController < ApplicationController
    include Stepable
    before_action :redirect_if_created, only: :new
    before_action :set_batch_state, only: :new
    before_action :set_previous_step_complete, only: :new
    before_action :set_step, only: :show

    def new
      @step = Step::Process.new(batch: @batch)
    end

    def create
      respond_to do |format|
        @step = Step::Process.new(batch: @batch)
        if @step.update(process_params)
          format.html do
            @batch.start!
            # TODO: kickoff job i.e. JOB.perform_later(@step)
            redirect_to batch_step_process_path(
              @batch, @batch.step_process
            ), notice: t('batch.step.process.created')
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

    private

    def process_params
      # params.require(:step_process).permit(:message)
      {}
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
      @batch.step_preprocess.update(done: true) unless @batch.step_preprocess.done?
    end

    def set_step
      @step = authorize(@batch).step_process
    end
  end
end
