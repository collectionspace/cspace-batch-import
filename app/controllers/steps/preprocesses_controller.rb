# frozen_string_literal: true

class Steps::PreprocessesController < ApplicationController
  before_action :set_batch

  def new
    if @batch.step_preprocess
      return redirect_to batch_steps_preprocess_path(
        @batch, @batch.step_preprocess
      )
    end
    # TODO: batch.step :preprocess, batch.[status].ready!
    @preprocess = Step::Preprocess.new(batch: @batch)
  end

  def create
    respond_to do |format|
      @preprocess = Step::Preprocess.new(batch: @batch)
      if @preprocess.update(preprocess_params)
        format.html do
          # TODO: batch.[status].pending!
          # TODO: kickoff job i.e. JOB.perform_later(@preprocess)
          redirect_to batch_steps_preprocess_path(
            @batch, @batch.step_preprocess
          ), notice: t('step.preprocess.created')
        end
      else
        format.html do
          @preprocess = Step::Preprocess.new(batch: @batch)
          render :new
        end
      end
    end
  end

  def show; end

  private

  def preprocess_params
    # params.require(:step_preprocess).permit(:message)
    {}
  end

  def set_batch
    @batch = authorize Batch.find(params[:batch_id])
  end
end
