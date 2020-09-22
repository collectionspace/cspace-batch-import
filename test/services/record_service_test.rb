# frozen_string_literal: true

require 'test_helper'

class RecordServiceTest < ActiveSupport::TestCase
  include CachingHelper

  setup do
    @uri = '/collectionobjects/998b6cad-4a55-4904-93b2'
    @identifier = 'xyz'
    @rs = RecordService.new(
      namespace: 'b1', client: users(:superuser).connections.first.client
    )
  end

  test 'can add found uri to cache' do
    with_caching do
      @rs.stub :request, @uri do
        uri = @rs.lookup(type: 'collectionobjects', subtype: nil, identifier: @identifier)
        assert_equal @uri, uri
        assert_equal @uri, @rs.get(identifier: @identifier)
      end
    end
  end

  test 'will add false for not found to cache' do
    with_caching do
      @rs.stub :request, false do
        uri = @rs.lookup(type: 'collectionobjects', subtype: nil, identifier: @identifier)
        assert_equal false, uri
        assert_equal false, @rs.get(identifier: @identifier)
      end
    end
  end

  test 'can reset cache' do
    with_caching do
      @rs.stub :request, @uri do
        @rs.lookup(type: 'collectionobjects', subtype: nil, identifier: @identifier)
        assert_equal @uri, @rs.get(identifier: @identifier)
        @rs.reset
        assert_equal nil, @rs.get(identifier: @identifier)
      end
    end
  end
end
