# frozen_string_literal: true

module WorkflowMetadata
  extend ActiveSupport::Concern

  def current_runtime
    ((completed_at || Time.current.utc) - started_at).round
  end

  def done?
    done
  end

  def percentage_complete?
    (step_num_row * 100 / (batch.num_rows || 10))
  end
end
