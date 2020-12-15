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
      handler = process.batch.handler
      rs = RecordManagerService.new(client: process.batch.connection.client)
      
      manager.process do |data|
        row_data = { 'err' => [], 'warn' => [] }
        
        result = handler.process(data)
        id = result.identifier
        if id.empty?
          row_data['err'] << 'No record identifier'
        end
        
        #manager.log!('ok', I18n.t('csv.ok'))
        process.row_results[manager.row_num] = row_data
        process.save
      end
      
      manager.complete!
    rescue StandardError => e
      manager.exception!
      Rails.logger.error(e.message)
      Rails.logger.error(e.backtrace)
    end
  end
end
