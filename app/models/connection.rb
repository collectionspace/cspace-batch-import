# frozen_string_literal: true

class Connection < ApplicationRecord
  belongs_to :user
  encrypts :password
  after_initialize :find_domain, if: :new_record?
  before_save :unset_primary, if: -> { disabled? && primary? }
  validates :name, presence: true
  validates :url, presence: true
  validates :username, presence: true
  validates :password, presence: true

  def disabled?
    !enabled?
  end

  def enabled?
    enabled
  end

  def find_domain
    # TODO: lookup domain
  end

  def primary?
    primary
  end

  def unset_primary
    self.primary = false
  end

  def self.primary(user, connection)
    where(user_id: user.id)
      .where.not(id: connection.id)
      .update_all(primary: false)
    connection.update(primary: true)
  end
end
