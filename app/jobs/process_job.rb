# frozen_string_literal: true
require 'pp'

class ProcessJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: false
  ERRORS = [:message].freeze

  def perform(process)
    manager = StepManagerService.new(
      step: process, error_on_warning: false, save_to_file: false
    )
    return if manager.cut_short?

    manager.kickoff!

    begin
      handler = process.batch.handler
      rs = RecordManagerService.new(client: process.batch.connection.client)
      mts = MissingTermService.new(batch: process.batch, save_to_file: true)
      manager.add_file(mts.missing_term_occurrence_file, 'text/csv', :tmp)

      rep = ReportService.new(name: "#{manager.filename_base}_processed.#{FILE_TYPE}",
        columns: %i[row row_status message category],
        save_to_file: true)
      manager.add_file(rep.file, 'text/csv', :tmp)

      manager.process do |data|
        begin
          result = handler.process(data)
        rescue StandardError => e
          manager.add_warning!
          rep.append(process.step_num_row, 'warning', "Mapper did not return result: #{e.message}", 'mapper')
          manager.add_message("Mapping failed for one or more records")
          next	
        end

        unless result.terms.empty?
          missing_terms = mts.get_missing(result.terms)
          missing_terms.each{ |term| mts.add(term, manager.row_num) }
          msgs = missing_terms.map{ |term| mts.message(term) }.join('; ')
          manager.add_warning!
          rep.append(process.step_num_row, 'warning', msgs, 'terms')
        end


        unless result.warnings.empty?
          result.warnings.each{ |warning| manager.handle_processing_warning(rep, warning) }
        end
        
        # id = result.identifier
        # if id.empty?
        #   row_data['err'] << 'No record identifier'
        # end
        
        # #manager.log!('ok', I18n.t('csv.ok'))
        process.save
      end

      # post-process across-batch reports
      ## unique missing terms
      mts.report_uniq_missing_terms
      manager.add_file(mts.uniq_missing_terms_file, 'text/csv')
      if mts.total_terms > 0
        manager.add_message("Batch contains #{mts.total_terms} unique terms that do not exist in CollectionSpace")
        manager.add_message("Batch contains #{mts.total_term_occurrences} uses of terms that do not exist in CollectionSpace")
      end

      manager.finalize_main_processing_report(rep)
      
      #      manager.complete!
      manager.exception!
    rescue StandardError => e
      manager.exception!
      Rails.logger.error(e.message)
      Rails.logger.error(e.backtrace)
    end
  end
end
