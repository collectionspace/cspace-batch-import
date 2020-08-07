# frozen_string_literal: true

class Role < ApplicationRecord
  has_many :users

  TYPE = {
    admin: 'Admin',
    manager: 'Manager',
    member: 'Member'
  }.freeze

  scope :admin, -> { where(name: TYPE[:admin]).first }
  scope :default, -> { where(name: TYPE[:member]).first }
  scope :manager, -> { where(name: TYPE[:manager]).first }
  scope :member, -> { where(name: TYPE[:member]).first }
  scope :role_options, ->(user) { user.admin? ? all : where.not(name: TYPE[:admin]) }

  def manage?(user, record)
    "Role::#{user.role.name}".constantize.new.manage?(user, record)
  end

  class Admin
    def manage?(_user, _record)
      true
    end
  end

  class Manager
    def manage?(user, record)
      return true if user == record
      return false if record.respond_to?(:role) && record.role == Role.admin

      if record.respond_to? :group
        user.group.id == record.group.id
      elsif record.respond_to? :user
        user.group.id == record.user.group.id
      else
        false
      end
    end
  end

  class Member
    def manage?(user, record)
      return true if user == record
      return true if record.respond_to?(:user) && user.id == record.user.id
    end
  end
end
