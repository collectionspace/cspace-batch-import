# frozen_string_literal: true

class PreprocessJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: false
  ERRORS = [:message].freeze
  PREPROCESS_FIELD_REPORT_COLS = [:header, :known].freeze

  def perform(preprocess)
    step = StepManagerService.new(
      step: preprocess, error_on_warning: false, save_to_file: !Rails.env.test?
    )
    return if step.cut_short?

    step.kickoff!

    begin
      field_report = ReportService.new(
        name: 'fields', columns: PREPROCESS_FIELD_REPORT_COLS, save_to_file: !Rails.env.test?
      )
      step.add_file field_report.file, 'text/csv'
      handler = preprocess.batch.handler
      step.process do |data|
        if step.first?
          result = handler.check_fields(data)
          step.add_message("#{I18n.t('csv.preprocess_known_prefix')}: #{result[:known_fields].count}")
          step.add_message("#{I18n.t('csv.preprocess_unknown_prefix')}: #{result[:unknown_fields].count}")
          result[:known_fields].each { |f| field_report.add_message({ header: f, known: true }) }

          if result[:unknown_fields].any?
            step.add_warning!
            result[:unknown_fields].each { |f| field_report.add_message({ header: f, known: false }) }
          end
        end

        validated = handler.validate(data)
        unless validated.valid?
          validated.errors.each do |e|
            step.add_error!
            step.log!('error', e.values_at(*ERRORS).join(';'))
          end
        end

        step.log!('ok', I18n.t('csv.ok')) if validated.valid?
      end

      step.complete!
    rescue StandardError => e
      # something really bad happened! we need to make this prominent somewhere ...
      step.exception!
      Rails.logger.error(e.message)
      Rails.logger.error(e.backtrace)
    end
  end
end
