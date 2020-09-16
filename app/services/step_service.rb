# frozen_string_literal: true

class StepService
  attr_reader :step
  def initialize(step:, save_to_file:)
    @step = step
    @save_to_file = save_to_file
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

  def failed!
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
