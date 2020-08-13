require 'test_helper'

class MappersControllerTest < ActionDispatch::IntegrationTest
  test 'an admin can view mappers' do
    sign_in users(:admin)
    assert_can_view(mappers_path)
  end

  test 'a manager cannot view mappers' do
    sign_in users(:manager)
    refute_can_view(mappers_path)
  end

  test 'a member cannot view mappers' do
    sign_in users(:minion)
    refute_can_view(mappers_path)
  end
end
