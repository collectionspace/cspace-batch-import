# frozen_string_literal: true

class ArchiveJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: false
  ERRORS = [:message].freeze

  def perform(archive)
    step = StepManagerService.new(
      step: archive, error_on_warning: false, save_to_file: !Rails.env.test?
    )
    return if step.cut_short?

    step.kickoff!

    begin
      archive.update(step_num_row: archive.batch.num_rows)
      step.complete!
    rescue StandardError => e
      step.exception!
      Rails.logger.error(e.message)
      Rails.logger.error(e.backtrace)
    end
  end
end
