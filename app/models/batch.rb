# frozen_string_literal: true

class Batch < ApplicationRecord
  include WorkflowManager
  has_one_attached :spreadsheet
  has_one :step_preprocess, class_name: 'Step::Preprocess', dependent: :destroy
  has_one :step_process, class_name: 'Step::Process', dependent: :destroy
  belongs_to :user
  belongs_to :group
  belongs_to :connection
  belongs_to :mapper, counter_cache: true
  validates :name, :spreadsheet, :user, :group, :connection, :mapper, presence: true
  validate :connection_profile_is_matched

  def processed?
    step_process&.done?
  end

  def preprocessed?
    step_preprocess&.done?
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
