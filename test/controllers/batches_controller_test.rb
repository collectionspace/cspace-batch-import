require 'test_helper'

class BatchesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:admin)
  end

  test 'a user can view batches' do
    assert_can_view(batches_path)
  end

  test "a user can access the new batch form" do
    assert_can_view(new_batch_path)
  end
end
