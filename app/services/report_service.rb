# frozen_string_literal: true

class ReportService
  FILE_TYPE = 'csv'

  attr_reader :file, :headers

  def initialize(name:, columns:, save_to_file: false)
    @file = Rails.root.join('tmp', "#{name}-#{Time.now.to_i}.#{FILE_TYPE}")
    @headers = columns
    @save_to_file = save_to_file
    append(@headers) if @save_to_file
  end

  def add_message(message)
    append(message)
  end

  private

  def append(message)
    return unless @save_to_file

    CSV.open(file, 'a') do |csv|
      csv << (message.respond_to?(:key) ? message.values_at(*headers) : message.map(&:to_s))
    end
  end
end
