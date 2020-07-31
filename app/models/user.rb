# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :group
  belongs_to :role
  after_initialize :setup, if: :new_record?
  scope :superuser, -> { where(email: superuser_email).first }

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
    enabled && group.enabled?
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
    self.group ||= target_group
    self.role ||= Role.default
  end

  def self.superuser_created?
    User.where(
      email: superuser_email
    ).exists?
  end

  def self.superuser_email
    ENV.fetch('CSPACE_BATCH_IMPORT_SUPERUSER_EMAIL', 'superuser@collectionspace.org')
  end

  private

  def target_group
    g = Group.where(domain: email.split('@').last)
    g.exists? ? g.first : Group.default
  end
end
