# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  def active_for_authentication?
    super && active?
  end

  def active?
    active
  end

  def admin?
    admin
  end

  def self.admin_created?
    User.where(
      email: ENV.fetch('CSPACE_BATCH_IMPORT_ADMIN_EMAIL', 'admin@collectionspace.org')
    ).exists?
  end
end
