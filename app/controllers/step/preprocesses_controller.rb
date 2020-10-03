# frozen_string_literal: true

module Step
  class PreprocessesController < Step::WorkflowController
    def new
      @step = Step::Preprocess.new(batch: @batch)
    end

    def create
      respond_to do |format|
        @step = Step::Preprocess.new(batch: @batch)
        if @step.update(preprocess_params)
          format.html do
            @batch.start!
            job = PreprocessJob.perform_later(@step)
            @batch.update(job_id: job.provider_job_id)
            redirect_to batch_step_preprocess_path(
              @batch, @batch.step_preprocess
            )
          end
        else
          format.html do
            @step = Step::Preprocess.new(batch: @batch)
            render :new
          end
        end
      end
    end

    def show; end

    def cancel
      cancel!
      redirect_to batch_step_preprocess_path(
        @batch, @batch.step_preprocess
      )
    end

    def reset
      reset!
      redirect_to new_batch_step_preprocess_path(@batch)
    end

    private

    def preprocess_params
      {}
    end

    def redirect_if_created
      return unless @batch.step_preprocess

      redirect_to batch_step_preprocess_path(
        @batch, @batch.step_preprocess
      )
    end

    def set_batch_state
      @batch.preprocess! unless @batch.preprocessing?
    end

    def set_step
      @step = authorize(@batch).step_preprocess
    end
  end
end
