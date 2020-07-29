# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :group
  belongs_to :role
  after_initialize :setup, if: :new_record?

  def active_for_authentication?
    super && active?
  end

  def active?
    active
  end

  def admin?
    role.name == Role::TYPE[:admin]
  end

  def enabled?
    enabled
  end

  def is?(user)
    self == user
  end

  def manage?(record)
    return true if admin?
    return false unless manager?

    if record.respond_to? :group
      group.name == record.group.name
    elsif record.respond_to? :user
      group.name == record.user.group.name
    else
      false
    end
  end

  def manager?
    role.name == Role::TYPE[:manager]
  end

  def member?
    role.name == Role::TYPE[:member]
  end

  def role?(name)
    role.name == name
  end

  def setup
    self.group ||= Group.default
    self.role ||= Role.default
  end

  def self.admin_created?
    User.where(
      email: ENV.fetch('CSPACE_BATCH_IMPORT_ADMIN_EMAIL', 'admin@collectionspace.org')
    ).exists?
  end
end
