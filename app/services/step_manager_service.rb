# frozen_string_literal: true

class StepManagerService
  attr_accessor :error_on_warning
  attr_reader :file, :files, :headers, :messages, :step, :row_results
  FILE_TYPE = 'csv'
  HEADERS = %i[row row_status message].freeze

  def initialize(step:, error_on_warning:, save_to_file:)
    @files = []
    @messages = []
    @headers = HEADERS
    @step = step
    @error_on_warning = error_on_warning
    @save_to_file = save_to_file
    return unless @save_to_file

    time = Time.now
    filename = "#{step.prefix}_#{step.batch.name.parameterize}-#{time.strftime('%F').delete('-')}-#{time.strftime('%R').delete(':')}.#{FILE_TYPE}"
    @file = Rails.root.join('tmp', filename)
    @files << { file: @file, type: 'csv' }
    append(@headers)
  end

  def add_error!
    step.increment_error!
    step.batch.failed! unless step.batch.failed?
  end

  def add_file(file, content_type)
    return unless step.class::CONTENT_TYPES.include?(content_type)
    return unless File.file? file

    files << { file: file, content_type: content_type }
  end

  def add_message(message)
    messages << message
  end

  def add_warning!
    step.increment_warning!
    step.batch.failed! if error_on_warning && !step.batch.failed?
  end

  def attach!
    step.update(messages: messages)
    return if files.empty?

    files.each do |f|
      step.reports.attach(
        io: File.open(f[:file]),
        filename: File.basename(f[:file]),
        content_type: f[:content_type]
      )
    end
  end

  def cancelled?
    step.cancelled?
  end

  def complete!
    unless cancelled? || errors?
      step.batch.finished!
      step.update(done: true)
    end
    finishup!
  end

  def cut_short?
    running? || cancelled?
  end

  def errors?
    step.errors?
  end

  def exception!
    # may already be in trouble
    step.batch.failed! unless step.batch.failed?
    finishup!
  end

  def first?
    step.step_num_row == 2 # after header
  end

  # TODO: test -- [ok, error, warning]
  # If save_to_file = true, send message for row to CSV file
  # If save_to_file = false, does nothing
  def log!(status, message)
    append({ row: step.step_num_row, row_status: status, message: message })
  end

  def finishup!
    step.update(completed_at: Time.now.utc)
    step.update_header # broadcast final status of step
    attach!
  end

  def kickoff!
    step.batch.run! # update status to running
    step.update(started_at: Time.now.utc)
    step.update_header # broadcast current status
    nudge! # increment for header
  end

  def nudge!
    step.increment_row!
    step.update_progress
  end

  def process
    step.batch.spreadsheet.open do |csv|
      csv = CSV.open(csv.path, headers: true, encoding: 'bom|utf-8')
      loop do
        break if cancelled?

        row = csv.shift
        break unless row

        nudge!
        yield row.to_hash
      rescue CSV::MalformedCSVError => e
        add_error!
        log!('error', e.message)
      end
    end
  end

  def row_num
    step.step_num_row
  end

  def running?
    step.running?
  end

  def warnings?
    step.warnings?
  end

  private

  def append(message)
    return unless @save_to_file

    CSV.open(file, 'a') do |csv|
      csv << (message.respond_to?(:key) ? message.values_at(*headers) : message.map(&:to_s))
    end
  end
end
