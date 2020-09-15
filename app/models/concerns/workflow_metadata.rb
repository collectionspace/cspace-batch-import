# frozen_string_literal: true

module WorkflowMetadata
  extend ActiveSupport::Concern
  include CableReady::Broadcaster
  CHECK_IN_INCREMENT = 5 # can checkin every 5% of the time

  def abort?
    return unless checkin?

    batch.reload.cancelled?
  end

  def checkin?
    # (((step_num_row.to_f / batch.num_rows) * 100) % 5).zero?
    (((step_num_row.to_f / 10) * 100) % CHECK_IN_INCREMENT).zero?
  end

  def current_runtime
    ((completed_at || Time.current.utc) - started_at).round
  end

  def done?
    done
  end

  def errors?
    step_errors.positive?
  end

  def increment!
    update(step_num_row: step_num_row + 1)
  end

  def percentage_complete?
    # (step_num_row * 100) / batch.num_rows
    (step_num_row * 100 / (10)) # TODO: replace placeholder job
  end

  def running?
    batch.reload.running?
  end

  def update_progress
    return unless checkin?

    selector = '#' + ActionView::RecordIdentifier.dom_id(self)
    action_view = ActionView::Base.new(ActionController::Base.view_paths, {})
    action_view.class.send(:include, ApplicationHelper)
    dom_html = action_view.render(
      file: 'step/_progress.html.erb', locals: { step: self }
    )

    cable_ready['step'].morph(selector: selector, html: dom_html)
    cable_ready.broadcast
  end

  def warnings?
    step_warnings.positive?
  end
end
