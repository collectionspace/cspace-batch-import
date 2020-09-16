# frozen_string_literal: true

class Batch < ApplicationRecord
  include WorkflowManager
  CONTENT_TYPES = [
    'application/vnd.ms-excel',
    'text/csv'
  ].freeze
  has_one_attached :spreadsheet
  has_one :step_preprocess, class_name: 'Step::Preprocess', dependent: :destroy
  has_one :step_process, class_name: 'Step::Process', dependent: :destroy
  belongs_to :user
  belongs_to :group
  belongs_to :connection
  belongs_to :mapper, counter_cache: true
  validates :spreadsheet, attached: true, content_type: CONTENT_TYPES
  validates :user, :group, :connection, :mapper, presence: true
  validates :name, presence: true, length: { minimum: 3 }
  validate :connection_profile_is_matched
  scope :working, -> { where.not(step_state: 'archiving') }
  scope :archived, -> { where(step_state: 'archiving') }

  def archived?
    false
  end

  def can_cancel?
    %i[pending running].include? current_status
  end

  def can_reset?
    %i[cancelled failed].include? current_status
  end

  def processed?
    step_process&.done?
  end

  def preprocessed?
    step_preprocess&.done?
  end

  def self.content_types
    CONTENT_TYPES
  end

  def self.validator_for(batch)
    # raise unless batch.spreadsheet.attached? # TODO

    batch.spreadsheet.open do |spreadsheet|
      # TODO: config from batch
      config = { 'header': true, 'delimiter': ',' }
      options = { limit_lines: 100 }
      validator = Csvlint::Validator.new(
        File.new(spreadsheet.path), config, nil, options
      )
      yield validator
    end
  end

  private

  def connection_profile_is_matched
    if connection && mapper
      return unless connection.profile != mapper.profile_version
    end

    errors.add(:profile, I18n.t('batch.invalid_profile'))
  end
end
