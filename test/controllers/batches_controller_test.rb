# frozen_string_literal: true

require 'test_helper'

class BatchesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:admin)
    @batch = batches(:minion_default_batch)
  end

  test 'a user can view batches' do
    assert_can_view(batches_path)
  end

  test 'a user can access the new batch form' do
    assert_can_view(new_batch_path)
  end

  test 'should destroy batch' do
    assert_difference('Batch.count', -1) do
      delete batch_url(@batch)
    end

    assert_redirected_to batches_path
  end
end
