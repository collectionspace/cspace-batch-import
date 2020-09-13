# frozen_string_literal: true

require 'test_helper'

class BatchTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess
  setup do
    @params = {
      name: 'batch1',
      user_id: users(:superuser).id,
      group_id: users(:superuser).group.id,
      connection_id: connections(:core_superuser).id,
      mapper_id: mappers(:core_collectionobject_6_0).id,
      spreadsheet: fixture_file_upload('files/core-cataloging.csv', 'text/csv')
    }
    @invalid_params = @params.dup
  end

  test 'cannot create batch without a name' do
    @params.delete(:name)
    refute Batch.new(@params).valid?
  end

  test 'cannot create batch without a user' do
    @params.delete(:user_id)
    refute Batch.new(@params).valid?
  end

  test 'cannot create batch without a group' do
    @params.delete(:group_id)
    refute Batch.new(@params).valid?
  end

  test 'cannot create batch without a connection' do
    @params.delete(:connection_id)
    Batch.new(@params).valid?
  end

  test 'cannot create batch without a mapper' do
    @params.delete(:mapper_id)
    refute Batch.new(@params).valid?
  end

  test 'can create a batch with valid params' do
    assert Batch.new(@params).valid?
  end

  test 'cannot create a batch with invalid params' do
    @invalid_params[:mapper_id] = mappers(:anthro_collectionobject_4_1).id
    assert_not Batch.new(@invalid_params).valid?
  end
end
