# frozen_string_literal: true

class Group < ApplicationRecord
  has_many :users
  validate :profile_must_be_prefix
  validates :name, presence: true, uniqueness: true
  validates :supergroup, uniqueness: true, if: -> { supergroup }
  scope :default, -> { where(supergroup: true).first }
  scope :group_options, ->(user) { user.admin? ? all : where(id: user.group.id) }

  def default?
    self == Group.default
  end

  def disabled?
    !enabled?
  end

  def enabled?
    enabled
  end

  def self.default_created?
    Group.default
  end

  private

  def profile_must_be_prefix
    if profile.present? && !Mapper.mapper_profiles.include?(profile)
      errors.add(:profile, I18n.t('group.invalid_profile'))
    end
  end
end
