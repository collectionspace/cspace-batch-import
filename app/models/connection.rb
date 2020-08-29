# frozen_string_literal: true

class Connection < ApplicationRecord
  include PrefixChecker
  belongs_to :user
  has_one :group, through: :user
  encrypts :password
  before_save :resolve_primary, if: -> { primary? }
  before_save :unset_primary, if: -> { disabled? && primary? }
  after_save :set_domain
  validate :profile_must_be_prefix
  validates :name, presence: true
  validates :url, presence: true
  validates :username, presence: true
  validates :password, presence: true, length: { minimum: 6, maximum: 18 }

  def client
    CollectionSpace::Client.new(
      CollectionSpace::Configuration.new(
        base_uri: url,
        username: username,
        password: password
      )
    )
  end

  def disabled?
    !enabled?
  end

  def enabled?
    enabled
  end

  def resolve_primary
    Connection.resolve_primary(user, self)
  end

  def primary?
    primary
  end

  def unset_primary
    self.primary = false
  end

  def self.resolve_primary(user, connection)
    where(user_id: user.id)
      .where.not(id: connection.id)
      .update_all(primary: false)
  end

  private

  def set_domain
    update_column :domain, client.domain
  rescue CollectionSpace::RequestError => e
    update_columns(domain: nil, enabled: false, primary: false)
    logger.error(e.message)
  end
end
