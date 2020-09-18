# frozen_string_literal: true

class StepService
  attr_accessor :error_on_warning
  attr_reader :step
  HEADERS = %i[row row_status message].freeze

  def initialize(step:, error_on_warning:, save_to_file:)
    @file = nil
    @headers = HEADERS
    @step = step
    @error_on_warning = error_on_warning
    @save_to_file = save_to_file
    append(@headers) if @save_to_file
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

  # TODO: test -- [ok, error, warning]
  def log!(status, message)
    append({row: step.step_num_row, row_status: status, message: message })
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

  private

  # TODO: DRY (term_manager)
  def append(message)
    return unless @save_to_file

    CSV.open(file, 'a') do |csv|
      csv << (message.respond_to?(:key) ? message.values_at(*headers) : message.map(&:to_s))
    end
  end
end
