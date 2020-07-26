# frozen_string_literal: true

class Role < ApplicationRecord
  has_many :users

  TYPE = {
    admin: 'Admin',
    manager: 'Manager',
    member: 'Member'
  }

  scope :role_options, ->(user) { user.admin? ? all : where.not(name: TYPE[:admin]) }
end
