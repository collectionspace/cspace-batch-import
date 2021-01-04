# frozen_string_literal: true

class RecordManagerService
  attr_reader :client, :namespace
  PATH_TO_TOTAL = %w[abstract_common_list totalItems].freeze
  PATH_TO_URI = %w[abstract_common_list list_item uri].freeze

  # given namespace (scoped to base_uri) do we need a cleverer cache key?
  def initialize(client:)
    @client = client
    @namespace = @client.config.base_uri
  end

  def delete(identifier:)
    Rails.cache.delete(identifier, namespace: namespace)
  end

  def get(identifier:)
    Rails.cache.read(identifier, namespace: namespace)
  end

  # TODO: callee catch exception
  def lookup(type:, subtype:, identifier:)
    if Rails.cache.exist?(identifier, namespace: namespace)
      return get(identifier: identifier)
    end

    val = request(type, subtype, identifier)
    Rails.cache.write(
      identifier, val, namespace: namespace, expires_in: 1.day
    )
    val
  end

  def reset
    Rails.cache.delete_matched(/#{namespace}/)
  end

  private

  def request(type, subtype, identifier)
    response = client.find(type: type, subtype: subtype, value: identifier)
    found = response.parsed.dig(*PATH_TO_TOTAL) == '1'
    uri = response.parsed.dig(*PATH_TO_URI) if found
    found ? uri : false
  end
end
