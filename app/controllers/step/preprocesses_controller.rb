# frozen_string_literal: true

class Step::PreprocessesController < ApplicationController
  include Stepable
  before_action :redirect_if_created, only: :new
  before_action :set_batch_state, only: :new

  def new
    @step = Step::Preprocess.new(batch: @batch)
  end

  def create
    respond_to do |format|
      @step = Step::Preprocess.new(batch: @batch)
      if @step.update(preprocess_params)
        format.html do
          @batch.start!
          # TODO: kickoff job i.e. JOB.perform_later(@step)
          redirect_to batch_step_preprocess_path(
            @batch, @batch.step_preprocess
          ), notice: t('batch.step.preprocess.created')
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

  private

  def preprocess_params
    # params.require(:step_preprocess).permit(:message)
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
end
