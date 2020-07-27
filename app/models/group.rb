# frozen_string_literal: true

class Group < ApplicationRecord
  has_many :users
  scope :default, -> { where(name: default_group_name).first }
  scope :group_options, ->(user) { user.admin? ? all : where(name: user.group.name) }

  def self.groups_for_select
    Group.all
  end

  def self.default_created?
    Group.where(
      name: Group.default_group_name
    ).exists?
  end

  def self.default_group_name
    'CollectionSpace'
  end
end
