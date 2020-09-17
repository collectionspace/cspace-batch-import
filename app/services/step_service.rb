# frozen_string_literal: true

class StepService
  attr_accessor :error_on_warning
  attr_reader :step
  def initialize(step:, error_on_warning:, save_to_file:)
    @step = step
    @error_on_warning = error_on_warning
    @save_to_file = save_to_file
  end

  def add_error!
    step.increment_error!
    step.batch.failed! unless step.batch.failed?
  end

  def add_warning!
    step.increment_warning!
    step.batch.failed! if error_on_warning && !step.batch.failed?
  end

  def cancelled?
    step.abort?
  end

  def complete!
    step.batch.finished! unless step.abort? || step.errors?
    finishup!
  end

  def cut_short?
    step.running? || step.abort?
  end

  def exception!
    # may already be in trouble
    step.batch.failed! unless step.batch.failed?
    finishup!
  end

  def finishup!
    step.update(completed_at: Time.now.utc)
    step.update_header # broadcast final status of step
    # TODO: attach files
  end

  def kickoff!
    step.batch.run! # update status to running
    step.update(started_at: Time.now.utc)
    step.update_header # broadcast current status
  end

  def nudge!
    step.increment_row!
    step.update_progress
  end
end
