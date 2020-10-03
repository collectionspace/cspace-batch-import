# frozen_string_literal: true

module Step
  class TransfersController < Step::WorkflowController
    def new
      @step = Step::Transfer.new(batch: @batch)
    end

    def create
      respond_to do |format|
        @step = Step::Transfer.new(batch: @batch)
        if @step.update(transfer_params)
          format.html do
            @batch.start!
            # TODO: kickoff job i.e. JOB.perform_later(@step)
            redirect_to batch_step_transfer_path(
              @batch, @batch.step_transfer
            )
          end
        else
          format.html do
            @step = Step::Transfer.new(batch: @batch)
            render :new
          end
        end
      end
    end

    def show; end

    def cancel
      cancel!
      redirect_to batch_step_transfer_path(
        @batch, @batch.step_transfer
      )
    end

    def reset
      reset!
      respond_to do |format|
        format.html { redirect_to new_batch_step_transfer_path(@batch) }
      end
    end

    private

    def transfer_params
      params.require(:step_transfer).permit(:action_create, :action_update, :action_delete)
    end

    def previous_step_complete?
      @batch.step_process&.done?
    end

    def redirect_if_created
      return unless @batch.step_transfer

      redirect_to batch_step_transfer_path(
        @batch, @batch.step_transfer
      )
    end

    def set_batch_state
      unless previous_step_complete?
        return redirect_back(fallback_location: batches_path)
      end

      @batch.transfer! unless @batch.transferring?
    end

    def set_step
      @step = authorize(@batch).step_transfer
    end
  end
end
