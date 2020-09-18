# frozen_string_literal: true

class RecordService
  attr_reader :client, :namespace
  PATH_TO_TOTAL = %w[abstract_common_list totalItems].freeze
  PATH_TO_URI = %w[abstract_common_list list_item uri].freeze

  # given namespace (scoped to batch) do we need a cleverer cache key?
  def initialize(namespace:, client:)
    @client = client
    @namespace = namespace
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

  private

  def request(type, subtype, identifier)
    response = client.find(type: type, subtype: subtype, value: identifier)
    found = response.parsed.dig(*PATH_TO_TOTAL) == '1'
    uri = response.parsed.dig(*PATH_TO_URI) if found
    found ? uri : false
  end
end
