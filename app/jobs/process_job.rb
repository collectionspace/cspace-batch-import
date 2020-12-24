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
      rs = RecordManagerService.new(batch: process.batch)

      rep = ReportService.new(name: "#{manager.filename_base}_processed",
        columns: %i[row row_status message category],
        save_to_file: true)
      manager.add_file(rep.file, 'text/csv', :tmp)

      rus = RecordUniquenessService.new(batch: process.batch, log_report: rep)

      mts = MissingTermService.new(batch: process.batch, save_to_file: true)
      manager.add_file(mts.missing_term_occurrence_file, 'text/csv', :tmp)

      manager.process do |data|
        row_num = process.step_num_row
        data = data.compact
        begin
          result = handler.process(data)
        rescue StandardError => e
          manager.add_warning!
          rep.append({row: row_num,
                      row_status: 'warning',
                      message: "Mapper did not return result: #{e.message}",
                      category: 'mapper'
                     })
          manager.add_message("Mapping failed for one or more records")
          next	
        end
        
        unless result.terms.empty?
          puts 'Handling missing terms'
          missing_terms = mts.get_missing(result.terms)
          missing_terms.each{ |term| mts.add(term, row_num) }
          msgs = missing_terms.map{ |term| mts.message(term) }.join('; ')
          manager.add_warning!
          rep.append({row: row_num,
                      row_status: 'warning',
                      message: msgs,
                      category: 'terms'
                     })
        end

        unless result.warnings.empty?
          puts 'Handling warnings'
          result.warnings.each{ |warning| manager.handle_processing_warning(rep, warning) }
        end

        puts 'Handling record identifier'
        id = result.identifier
        if id.nil? || id.empty?
          manager.add_error!
          rep.append({row: row_num,
                      row_status: 'error',
                      message: "Identifier for record not found or created",
                      category: 'record identifier'
                     })
          manager.add_message("No identifier value for one or more records")
        else
          rus.add(row: row_num, id: id)
        end

        rs.cache_processed(row_num, result)

        process.save
      end

      # post-process across-batch reports
      ## unique missing terms
      puts 'Reporting missing terms'
      mts.report_uniq_missing_terms
      manager.add_file(mts.uniq_missing_terms_file, 'text/csv')
      if mts.total_terms > 0
        manager.add_message("Batch contains #{mts.total_terms} unique terms that do not exist in CollectionSpace")
        manager.add_message("Batch contains #{mts.total_term_occurrences} uses of terms that do not exist in CollectionSpace")
      end

      puts 'Finding/reporting any non-unique record ids in batch'
      rus.check_for_non_unique
      if rus.any_non_uniq
        rus.report_non_uniq
        manager.add_warning!
        manager.add_message("#{rus.non_uniq_ct} rows have non-unique identifiers")
      end

      puts 'Preparing final processing report'
      manager.finalize_main_processing_report(rep)
      
      #manager.complete!
      manager.exception!
    rescue StandardError => e
      manager.exception!
      Rails.logger.error(e.message)
      Rails.logger.error(e.backtrace)
    end
  end
end
