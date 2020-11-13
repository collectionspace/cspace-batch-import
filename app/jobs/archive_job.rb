# frozen_string_literal: true

class ArchiveJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: false
  ERRORS = [:message].freeze

  def perform(archive)
    manager = StepManagerService.new(
      step: archive, error_on_warning: false, save_to_file: !Rails.env.test?
    )
    return if manager.cut_short?

    manager.kickoff!

    begin
      archive.update(step_num_row: archive.batch.num_rows)
      manager.complete!
    rescue StandardError => e
      manager.exception!
      Rails.logger.error(e.message)
      Rails.logger.error(e.backtrace)
    end
  end
end
