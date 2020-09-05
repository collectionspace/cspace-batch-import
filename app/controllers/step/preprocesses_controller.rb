# frozen_string_literal: true

class Step::PreprocessesController < ApplicationController
  before_action :set_batch
  before_action :set_batch_state, only: :new
  before_action :set_preprocess, only: :show

  def new
    if @batch.step_preprocess
      return redirect_to batch_step_preprocess_path(
        @batch, @batch.step_preprocess
      )
    end
    @preprocess = Step::Preprocess.new(batch: @batch)
  end

  def create
    respond_to do |format|
      @preprocess = Step::Preprocess.new(batch: @batch)
      if @preprocess.update(preprocess_params)
        format.html do
          @batch.start!
          # TODO: kickoff job i.e. JOB.perform_later(@preprocess)
          redirect_to batch_step_preprocess_path(
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

  def set_batch_state
    @batch.preprocess! unless @batch.preprocessing?
  end

  def set_preprocess
    @preprocess = @batch.step_preprocess
  end
end
