# frozen_string_literal: true

class Group < ApplicationRecord
  include PrefixChecker
  has_many :users
  has_many :connections, through: :users
  after_save :update_connection_profiles, if: -> { profile? }
  validate :profile_must_be_prefix
  validates :name, presence: true, uniqueness: true
  validates :supergroup, uniqueness: true, if: -> { supergroup }
  validates_uniqueness_of :domain, allow_blank: true
  scope :default, -> { where(supergroup: true).first }
  scope :group_options, ->(user) { user.admin? ? all : where(id: user.group.id) }

  def default?
    self == Group.default
  end

  def disabled?
    !enabled?
  end

  def enabled?
    enabled
  end

  def self.default_created?
    Group.default
  end

  def profile?
    !profile.blank?
  end

  def self.matching_domain?(domain)
    return [] if domain.blank?

    Group.all.select do |g|
      next if g.domain.blank?

      domain.end_with?(g.domain)
    end.sort_by { |g| domain.length - g.domain.length }
  end

  private

  def update_connection_profiles
    connections.update_all(profile: profile)
  end
end
