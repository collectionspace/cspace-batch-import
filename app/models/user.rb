# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :connections
  belongs_to :group
  belongs_to :role
  after_initialize :setup, if: :new_record?
  before_save :reset_admin_group
  validates :superuser, uniqueness: true, if: -> { superuser }
  scope :superuser, -> { where(superuser: true).first }

  def active_for_authentication?
    super && active?
  end

  def active?
    active
  end

  def admin?
    role == Role.default_scoped.admin
  end

  def disabled?
    !enabled?
  end

  def enabled?
    enabled && group.enabled?
  end

  def is?(user)
    self == user
  end

  def manage?(record)
    "Role::#{role.name}".constantize.new(self).manage?(record)
  end

  def manager?
    role == Role.manager
  end

  def member?
    role == Role.member
  end

  def owner_of?(record)
    self == record.user if record.respond_to?(:user)
  end

  def role?(name)
    role.name == name
  end

  def setup
    self.group ||= target_group
    self.role ||= target_role
    self.enabled ||= self.role == Role.manager
  end

  def superuser?
    is?(User.superuser)
  end

  def self.superuser_created?
    User.superuser
  end

  private

  def reset_admin_group
    self.group = Group.default if self.role == Role.admin
  end

  def target_group
    g = Group.matching_domain?(email.split('@').last)
    g.any? ? g.first : Group.default
  end

  def target_role
    if self.group != Group.default && self.group.users.count.zero?
      Role.manager
    else
      Role.default
    end
  end
end
