# frozen_string_literal: true

class Mapper < ApplicationRecord
  self.inheritance_column = :_type_disabled
  validates :profile, presence: true
  validates :type, presence: true
  validates :url, presence: true, uniqueness: true

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
          profile: m['profile'], type: m['type']
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
end
