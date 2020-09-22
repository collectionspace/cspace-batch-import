# frozen_string_literal: true

class TermManagerService
  attr_reader :file, :headers, :found, :not_found
  FILE_TYPE = 'csv'
  HEADERS = %i[category type subtype value found].freeze

  # tm = TermManagerService.new(name: 'batch1', save_to_file: true)
  # CSV.foreach(tm.file, headers: true) { |row| puts row }
  def initialize(name:, save_to_file: false)
    @all = { found: {}, not_found: {} }
    @file = File.join(Dir.tmpdir, "#{name}-#{Time.now.to_i}.#{FILE_TYPE}")
    @found = @all[:found] = Hash.new { |h, k| h[k] = Set.new }
    @headers = HEADERS
    @not_found = @all[:not_found] = Hash.new { |h, k| h[k] = Set.new }
    @save_to_file = save_to_file
    append(@headers) if @save_to_file
  end

  def add(term)
    term[:found] ? add_found(term) : add_not_found(term)
  end

  def add_found(term)
    return unless term[:found]

    add_term(term, :found)
  end

  def add_not_found(term)
    return if term[:found]

    add_term(term, :not_found)
  end

  def fingerprint(term)
    Digest::MD5.hexdigest(term.to_s)
  end

  def total_found
    total(:found)
  end

  def total_not_found
    total(:not_found)
  end

  private

  def add_term(term, where)
    fp = fingerprint(term)
    return if @all[where][term[:type]].include?(fp)

    @all[where][term[:type]].add fp
    append(term)
  end

  def append(term)
    return unless @save_to_file

    CSV.open(file, 'a') do |csv|
      csv << (term.respond_to?(:key) ? term.values_at(*headers) : term.map(&:to_s))
    end
  end

  def total(where)
    @all[where].inject(0) { |t, h| t + h[1].size }
  end
end
