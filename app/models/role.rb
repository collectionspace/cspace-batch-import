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
  scope :select_options, ->(user) { user.admin? ? all : where.not(name: TYPE[:admin]) }

  class Type
    attr_reader :user
    def initialize(user)
      @user = user
    end

    def eligible?(record)
      return false if record.nil?

      true
    end
  end

  class Admin < Type
    def collaborator?(_record)
      true
    end

    def manage?(record)
      return false unless eligible?(record)

      collaborator?(record)
    end
  end

  class Manager < Type
    def collaborator?(record)
      return true if user.is?(record)
      return true if user.group?(record)

      if record.respond_to?(:group)
        user.group.id == record.group.id
      elsif record.respond_to?(:user)
        user.group.id == record.user.group.id
      end
    end

    def eligible?(record)
      return false if record.nil?
      return false if record.respond_to?(:role) && record.admin?

      true
    end

    def manage?(record)
      return false unless eligible?(record)

      collaborator?(record)
    end
  end

  class Member < Type
    def collaborator?(record)
      return true if user.is?(record) || user.owner_of?(record)
    end

    def manage?(record)
      return false unless eligible?(record)

      collaborator?(record)
    end
  end
end
