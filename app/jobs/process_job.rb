# frozen_string_literal: true

class ProcessJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: false
  ERRORS = [:message].freeze

  def perform(process)
    manager = StepManagerService.new(
      step: process, error_on_warning: false, save_to_file: !Rails.env.test?
    )
    return if manager.cut_short?

    manager.kickoff!

    begin
      manager.process do |data|
        manager.log!('ok', I18n.t('csv.ok'))
      end

      manager.complete!
    rescue StandardError => e
      manager.exception!
      Rails.logger.error(e.message)
      Rails.logger.error(e.backtrace)
    end
  end
end
