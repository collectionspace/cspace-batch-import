# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  discard_on ActiveJob::DeserializationError

  def cancelled?
    Sidekiq.redis { |c| c.exists?("cancelled-#{provider_job_id}") }
  end

  def self.cancel!(provider_job_id)
    Sidekiq.redis { |c| c.setex("cancelled-#{provider_job_id}", 86_400, 1) }
  end

  def update_progress(step)
    selector = '#' + ActionView::RecordIdentifier.dom_id(step)
    dom_html = ActionView::Base.new(ActionController::Base.view_paths, {})
                               .render(file: 'step/_progress.html.erb', locals: { step: step })

    cable_ready['step'].morph(selector: selector, html: dom_html)
    cable_ready.broadcast
  end
end
