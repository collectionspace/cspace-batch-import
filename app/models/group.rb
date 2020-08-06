# frozen_string_literal: true

class Group < ApplicationRecord
  has_many :users
  validates :name, presence: true, uniqueness: true
  scope :default, -> { where(name: default_group_name).first }
  scope :group_options, ->(user) { user.admin? ? all : where(id: user.group.id) }

  def disabled?
    !enabled?
  end

  def enabled?
    enabled
  end

  def self.default_created?
    Group.where(
      name: Group.default_group_name
    ).exists?
  end

  def self.default_group_name
    Rails.configuration.default_group
  end
end
