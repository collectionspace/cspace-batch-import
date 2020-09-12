# frozen_string_literal: true

require 'test_helper'

class BatchesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:admin)
    @valid_params = {
      name: 'batch1',
      group_id: groups(:default).id,
      connection_id: connections(:core_superuser).id,
      mapper_id: mappers(:core_collectionobject_6_0).id,
      spreadsheet: fixture_file_upload('files/core-cataloging.csv', 'text/csv')
    }
    @invalid_params = @valid_params.dup
  end

  test 'a user can view batches' do
    assert_can_view(batches_path)
  end

  test 'a user can access the new batch form' do
    assert_can_view(new_batch_path)
  end

  test 'should create a batch' do
    assert_difference('Batch.count') do
      post batches_url, params: { batch: @valid_params }
    end

    assert_response :redirect
    follow_redirect!
    assert_response :success
    assert_equal 'core-cataloging.csv', Batch.last.spreadsheet.filename.to_s
  end

  test 'should not create a batch with an invalid mapper' do
    @invalid_params[:mapper_id] = mappers(:anthro_collectionobject_4_1).id
    assert_no_difference('Batch.count') do
      post batches_url, params: { batch: @invalid_params }
    end
  end

  test 'should not create a batch with malformed csv' do
    @invalid_params[:spreadsheet] = fixture_file_upload('files/malformed.csv', 'text.csv')
    assert_no_difference('Batch.count') do
      post batches_url, params: { batch: @invalid_params }
    end
  end

  # TODO: admin can create batch for another group
  # TODO: non-admin user can create batch
  # TODO: cannot create a batch without a connection

  test 'should destroy batch' do
    batch = batches(:minion_batch)
    assert_difference('Batch.count', -1) do
      delete batch_url(batch)
    end

    assert_redirected_to batches_path
  end
end
