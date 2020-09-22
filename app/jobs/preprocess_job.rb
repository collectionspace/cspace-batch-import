# frozen_string_literal: true

class PreprocessJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: false

  def perform(preprocess)
    step = StepService.new(step: preprocess, error_on_warning: false, save_to_file: !Rails.env.test?)
    return if step.cut_short?

    step.kickoff!

    begin
      step.process do |_row|
        sleep 1
        step.log!('ok', I18n.t('csv.ok'))
      end

      # we'll call it good for now
      step.complete!
    rescue StandardError => e
      # something really bad happened! we need to make this prominent somewhere ...
      step.exception!
      Rails.logger.error(e.message)
      Rails.logger.error(e.backtrace)
    end
  end
end
