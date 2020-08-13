# frozen_string_literal: true

class Mapper < ApplicationRecord
  self.inheritance_column = :_type_disabled
  before_save :set_title
  validates :profile, presence: true
  validates :type, presence: true
  validates :version, presence: true
  validates :url, presence: true, uniqueness: true
  # TODO: scope mapper_options, ->(connection) { where(profile: connection.profile) }
  scope :mapper_profiles, -> { order(:profile).pluck(:profile).uniq }

  def found?
    status
  end

  def self.refresh
    mappers_url = Rails.configuration.mappers_url
    mappers_response = HTTP.get(mappers_url)
    return false unless mappers_response.status.success?

    begin
      JSON.parse(mappers_response.body.to_s)['mappers'].each do |m|
        Mapper.find_or_create_by!(\
          profile: m['profile'], version: m['version'], type: m['type']
        ) do |mapper|
          mapper.url = m['url']
          mapper.status = HTTP.get(mappers_url).status.success?
        end
      end
      true
    rescue StandardError => e
      logger.error(e.message)
      false
    end
  end

  private

  def set_title
    self.title = "#{profile}-#{type}-#{version}"
  end
end
