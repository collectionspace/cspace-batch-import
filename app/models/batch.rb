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
  validate :profile

  def processed?
    step_process&.done?
  end

  def preprocessed?
    step_preprocess&.done?
  end

  private

  def profile
    return unless connection.profile != mapper.profile_version

    errors.add(:profile, I18n.t('batch.invalid_profile'))
  end
end
