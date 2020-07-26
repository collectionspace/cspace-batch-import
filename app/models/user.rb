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

  def is?(user)
    self == user
  end

  def role?(role)
    role.name == role
  end

  # def manager?(record)
  #   return false unless role.name == Role::TYPE[:manager]

  #   if record.respond_to? :group
  #     group.name == record.group.name
  #   elsif record.respond_to? :user
  #     group.name == record.user.group.name
  #   else
  #     false
  #   end
  # end

  def setup
    self.group ||= Group.find_by(name: Group.default_group_name)
    self.role ||= Role.find_by(name: Role::TYPE[:member])
  end

  def self.admin_created?
    User.where(
      email: ENV.fetch('CSPACE_BATCH_IMPORT_ADMIN_EMAIL', 'admin@collectionspace.org')
    ).exists?
  end
end
