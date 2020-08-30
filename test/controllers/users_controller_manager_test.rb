# frozen_string_literal: true

require 'test_helper'

class UsersControllerAdminTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:manager)
  end

  test 'a manager can browse users from the same group' do
    assert_can_view users_path
  end

  test 'a manager can access self' do
    assert_can_view edit_user_path users(:manager)
  end

  test 'a manager can access a group member' do
    assert_can_view edit_user_path users(:minion)
  end

  test 'a manager can become a member' do
    post impersonate_user_path users(:minion)
    refute_can_view edit_user_path users(:manager)
  end

  test "a manager cannot access another group's member" do
    refute_can_view edit_user_path users(:salmon)
  end

  test 'a manager cannot become a member of another group' do
    post impersonate_user_path users(:salmon)
    refute_can_view edit_user_path users(:salmon)
  end

  test 'a manager can update a member' do
    user = users(:minion)
    run_update(
      user_url(user),
      user,
      { user: { enabled: false } },
      edit_user_path(user)
    )
    assert_equal user.enabled, false
  end

  test "a manager cannot update a member's group" do
    user = users(:minion)
    run_update(
      user_url(user),
      user,
      { user: { group_id: groups(:fish).id } },
      edit_user_path(user)
    )
    assert_not_equal user.group_id, groups(:fish).id
  end

  test 'a manager can promote a user to be manager' do
    user = users(:minion)
    run_update(
      user_url(user),
      user,
      { user: { role_id: roles(:manager).id } },
      edit_user_path(user)
    )
    assert_equal user.role_id, roles(:manager).id
  end

  test 'a manager cannot promote a user to be admin' do
    user = users(:minion)
    run_update(
      user_url(user),
      user,
      { user: { role_id: roles(:admin).id } },
    )
    assert_not_equal user.role.name, roles(:admin).name
  end
end
