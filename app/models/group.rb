# frozen_string_literal: true

class Group < ApplicationRecord
  has_many :users

  def self.groups_for_select
    Group.all
  end

  def self.default_created?
    Group.where(
      name: 'Default'
    ).exists?
  end
end
