# frozen_string_literal: true

class Group < ApplicationRecord
  has_many :users
  validates :name, presence: true, uniqueness: true
  scope :default, -> { where(default: true).first }
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
end
