# frozen_string_literal: true

class RecordManagerService
  attr_reader :batch, :client, :namespace
  PATH_TO_TOTAL = %w[abstract_common_list totalItems].freeze
  PATH_TO_URI = %w[abstract_common_list list_item uri].freeze

  # given namespace (scoped to base_uri) do we need a cleverer cache key?
  def initialize(batch:)
    @batch = batch
    @client = @batch.connection.client
    @mapper = get_mapper
    @service_type = @mapper['config']['service_type']
    @type = @mapper['config']['service_path']
    @subtype = @mapper['config']['authority_subtype']
    
    # @namespace = @client.config.base_uri
  end

  def cache_processed(rownum, result)
    key = "#{@batch.id}.#{rownum}"
    hash = {
      'xml' => result.doc.to_xml,
      'id' => result.identifier,
      'status' => result.record_status,
    }
    existing = {
      'csid' => result.csid,
      'uri' => result.uri,
      'refname' => result.refname
    }
    hash = hash.merge(existing) if result.record_status == :existing

    Rails.cache.write(key, hash, namespace: 'processed', expires_in: 1.day)
  end

    
  # def delete(identifier:)
  #   Rails.cache.delete(identifier, namespace: namespace)
  # end

  # def get(identifier:)
  #   Rails.cache.read(identifier, namespace: namespace)
  # end

  # # TODO: callee catch exception
  # # lookup(type: 'collectionobjects', identifier: '20CS.1980-32-1194')
  # # lookup(type: 'conditionchecks', identifier: '20CS.1980-32-1194')
  # # lookup(type: '
  # def lookup(type:, subtype: nil, identifier:)
  #   if Rails.cache.exist?(identifier, namespace: namespace)
  #     return get(identifier: identifier)
  #   end

  #   val = request(type, subtype, identifier)
  #   Rails.cache.write(
  #     identifier, val, namespace: namespace, expires_in: 1.day
  #   )
  #   val
  # end

  # def reset
  #   Rails.cache.delete_matched(/#{namespace}/)
  # end

  private

  def get_mapper
    Rails.cache.fetch(@batch.mapper.title, namespace: 'mapper', expires_in: 1.day) do
      JSON.parse(@batch.mapper.config.download)
    end
  end

  # def request(type, subtype, identifier)
  #   response = client.find(type: type, subtype: subtype, value: identifier)
  #   found = response.parsed.dig(*PATH_TO_TOTAL) == '1'
  #   uri = response.parsed.dig(*PATH_TO_URI) if found
  #   found ? uri : false
  # end
end
