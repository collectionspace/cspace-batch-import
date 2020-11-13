# frozen_string_literal: true

class PreprocessJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: false
  ERRORS = [:message].freeze
  PREPROCESS_FIELD_REPORT_COLS = [:header, :known].freeze

  def perform(preprocess)
    manager = StepManagerService.new(
      step: preprocess, error_on_warning: false, save_to_file: !Rails.env.test?
    )
    return if manager.cut_short?

    manager.kickoff!

    begin
      field_report = ReportService.new(
        name: 'fields', columns: PREPROCESS_FIELD_REPORT_COLS, save_to_file: !Rails.env.test?
      )
      manager.add_file field_report.file, 'text/csv'
      handler = preprocess.batch.handler
      manager.process do |data|
        if manager.first?
          result = handler.check_fields(data)
          manager.add_message("#{I18n.t('csv.preprocess_known_prefix')}: #{result[:known_fields].count}")
          manager.add_message("#{I18n.t('csv.preprocess_unknown_prefix')}: #{result[:unknown_fields].count}")
          result[:known_fields].each { |f| field_report.add_message({ header: f, known: true }) }

          if result[:unknown_fields].any?
            manager.add_warning!
            result[:unknown_fields].each { |f| field_report.add_message({ header: f, known: false }) }
          end
        end

        validated = handler.validate(data)
        unless validated.valid?
          validated.errors.each do |e|
            manager.add_error!
            manager.log!('error', e.values_at(*ERRORS).join(';'))
          end
        end

        manager.log!('ok', I18n.t('csv.ok')) if validated.valid?
      end

      manager.complete!
    rescue StandardError => e
      manager.exception!
      Rails.logger.error(e.message)
      Rails.logger.error(e.backtrace)
    end
  end
end
