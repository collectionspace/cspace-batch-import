# frozen_string_literal: true

module Stepable
  extend ActiveSupport::Concern

  included do
    before_action :set_batch, except: :create
    before_action :set_batch_for_create, only: :create
    before_action :set_step, only: :show
  end

  def set_batch
    @batch = authorize Batch.find(params[:batch_id])
  end

  def set_batch_for_create
    @batch = authorize Batch.find(params[:batch_id]), policy_class: Step::Policy
  end

  def set_step
    @step = authorize(@batch).step_preprocess
  end
end
