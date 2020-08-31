# frozen_string_literal: true

require 'test_helper'

class UsersControllerAdminTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:admin)
  end

  test 'an admin can browse users' do
    assert_can_view(users_path)
  end

  test 'an admin cannot access the superuser' do
    refute_can_view edit_user_path users(:superuser)
  end

  test 'an admin can access an admin' do
    assert_can_view edit_user_path users(:admin2)
  end

  test 'an admin can access a manager' do
    assert_can_view edit_user_path users(:manager)
  end

  test 'an admin can become a manager' do
    post impersonate_user_path users(:manager)
    refute_can_view edit_user_path users(:admin)
  end

  test "an admin can update a member's group" do
    user = users(:manager)
    run_update(
      user_url(user),
      user,
      { user: { group_id: groups(:fish).id } },
      edit_user_path(user)
    )
    assert_equal groups(:fish).name, user.group.name
  end

  test 'an admin can promote a user to be admin' do
    user = users(:manager)
    run_update(
      user_url(user),
      user,
      { user: { role_id: roles(:admin).id } },
      edit_user_path(user)
    )
    assert_equal roles(:admin).id, user.role_id
  end

  test 'an admin can delete a user (with connection)' do
    assert_difference('User.count', -1) do
      delete user_url(users(:minion))
    end

    assert_redirected_to users_url
  end
end
