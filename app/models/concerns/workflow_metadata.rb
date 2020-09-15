# frozen_string_literal: true

module WorkflowMetadata
  extend ActiveSupport::Concern

  # TODO: make this more sophisticated over time (check increments)
  def abort?
    batch.reload.cancelled?
  end

  def current_runtime
    ((completed_at || Time.current.utc) - started_at).round
  end

  def done?
    done
  end

  def percentage_complete?
    # (step_num_row * 100 / (batch.num_rows || 10))
    (step_num_row * 100 / (10)) # TODO: replace placeholder job
  end

  def running?
    batch.reload.running?
  end
end
