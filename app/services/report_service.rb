# frozen_string_literal: true

class ReportService
  FILE_TYPE = 'csv'

  attr_reader :file, :headers

  def initialize(name:, columns:, save_to_file: false)
    @file = Rails.root.join('tmp', "#{name}.#{FILE_TYPE}")
    @headers = columns
    @save_to_file = save_to_file
    append(@headers) if @save_to_file
  end

  def append(message)
    add_to_report(message)
  end

  private

  def add_to_report(message)
    return unless @save_to_file

    CSV.open(file, 'a') do |csv|
      csv << (message.respond_to?(:key) ? message.values_at(*headers) : message.map(&:to_s))
    end
  end
end
