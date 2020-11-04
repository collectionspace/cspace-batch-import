# frozen_string_literal: true

class TransferJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: false
  ERRORS = [:message].freeze

  def perform(process)
    step = StepManagerService.new(
      step: process, error_on_warning: false, save_to_file: !Rails.env.test?
    )
    return if step.cut_short?

    step.kickoff!

    begin
      step.process do |data|
        step.log!('ok', I18n.t('csv.ok'))
      end

      step.complete!
    rescue StandardError => e
      step.exception!
      Rails.logger.error(e.message)
      Rails.logger.error(e.backtrace)
    end
  end
end
