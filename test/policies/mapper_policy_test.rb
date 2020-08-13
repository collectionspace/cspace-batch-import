# frozen_string_literal: true

require 'test_helper'

class MapperPolicyTest < ActiveSupport::TestCase
  test 'admin can access mappers' do
    assert_permit MapperPolicy, users(:admin), nil, :index
  end

  test 'manager cannot access mappers' do
    refute_permit MapperPolicy, users(:manager), nil, :index
  end

  test 'member cannot access mappers' do
    refute_permit MapperPolicy, users(:minion), nil, :index
  end
end
