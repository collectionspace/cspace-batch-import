# frozen_string_literal: true

require 'test_helper'

class BatchesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:admin)
    @valid_params = {
      name: 'batch1',
      group_id: groups(:default).id
    }
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
