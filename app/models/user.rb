# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :group
  after_initialize :set_group, if: :new_record?

  def active_for_authentication?
    super && active?
  end

  def active?
    active
  end

  def admin?
    admin
  end

  def is?(user)
    self == user
  end

  # def manager?(record)
  #   return false unless role.name == Role.manager

  #   if record.respond_to? :group
  #     group.name == record.group.name
  #   elsif record.respond_to? :user
  #     group.name == record.user.group.name
  #   else
  #     false
  #   end
  # end

  def set_group
    self.group_id = Group.find_by(name: Group.default_group_name).id
  end

  def self.admin_created?
    User.where(
      email: ENV.fetch('CSPACE_BATCH_IMPORT_ADMIN_EMAIL', 'admin@collectionspace.org')
    ).exists?
  end
end
