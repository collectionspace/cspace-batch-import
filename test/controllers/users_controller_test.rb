# frozen_string_literal: true

require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  test 'an admin can browse users' do
    sign_in users(:admin)
    assert_can_view(users_path)
  end

  test 'an admin cannot access the superuser' do
    sign_in users(:admin)
    refute_can_view edit_user_path users(:superuser)
  end

  test 'an admin can access an admin' do
    sign_in users(:admin)
    assert_can_view edit_user_path users(:admin2)
  end

  test 'an admin can access a manager' do
    sign_in users(:admin)
    assert_can_view edit_user_path users(:manager)
  end

  test 'an admin can become a manager' do
    sign_in users(:admin)
    post impersonate_user_path users(:manager)
    refute_can_view edit_user_path users(:admin)
  end

  test "an admin can update a member's group" do
    sign_in users(:admin)
    user = users(:manager)
    assert_can_update(
      user_url(user),
      user,
      { user: { group_id: groups(:fish).id } },
      :group_id,
      groups(:fish).id,
      edit_user_path(user)
    )
  end

  test 'an admin can promote a user to be admin' do
    sign_in users(:admin)
    user = users(:manager)
    assert_can_update(
      user_url(user),
      user,
      { user: { role_id: roles(:admin).id } },
      :role_id,
      roles(:admin).id,
      edit_user_path(user)
    )
  end

  test 'a manager can browse users from the same group' do
    sign_in users(:manager)
    assert_can_view users_path
  end

  test 'a manager can access self' do
    sign_in users(:manager)
    assert_can_view edit_user_path users(:manager)
  end

  test 'a manager can access a group member' do
    sign_in users(:manager)
    assert_can_view edit_user_path users(:minion)
  end

  test 'a manager can become a member' do
    sign_in users(:manager)
    post impersonate_user_path users(:minion)
    refute_can_view edit_user_path users(:manager)
  end

  test "a manager cannot access another group's member" do
    sign_in users(:manager)
    refute_can_view edit_user_path users(:salmon)
  end

  test 'a manager cannot become a member of another group' do
    sign_in users(:manager)
    post impersonate_user_path users(:salmon)
    refute_can_view edit_user_path users(:salmon)
  end

  test 'a manager can update a member' do
    sign_in users(:manager)
    user = users(:minion)
    assert_can_update(
      user_url(user),
      user,
      { user: { enabled: false } },
      :enabled,
      false,
      edit_user_path(user)
    )
  end

  test "a manager cannot update a member's group" do
    sign_in users(:manager)
    user = users(:minion)
    refute_can_update(
      user_url(user),
      user,
      { user: { group_id: groups(:fish).id } },
      :group_id,
      groups(:fish).id,
      edit_user_path(user)
    )
  end

  test 'a manager can promote a user to be manager' do
    sign_in users(:manager)
    user = users(:minion)
    assert_can_update(
      user_url(user),
      user,
      { user: { role_id: roles(:manager).id } },
      :role_id,
      roles(:manager).id,
      edit_user_path(user)
    )
  end

  test 'a manager cannot promote a user to be admin' do
    sign_in users(:manager)
    user = users(:minion)
    refute_can_update(
      user_url(user),
      user,
      { user: { role_id: roles(:admin).id } },
      :role_id,
      roles(:admin).id,
      root_path
    )
  end

  test 'a member can browse users' do
    sign_in users(:minion)
    assert_can_view users_path
  end

  test 'a member can access self' do
    sign_in users(:minion)
    assert_can_view edit_user_path users(:minion)
  end

  test 'a member cannot access another user' do
    sign_in users(:minion)
    refute_can_view edit_user_path users(:manager)
  end

  test 'a member cannot become another member' do
    sign_in users(:minion)
    post impersonate_user_path users(:disabled)
    refute_can_view edit_user_path users(:disabled)
  end

  # DISABLED USER
  test 'a disabled user can sign in' do
    sign_in users(:disabled)
    get root_path
    assert_response :success
    assert_select 'article.message', /You are not currently assigned/
  end

  test 'a disabled user cannot update self' do
    sign_in users(:disabled)
    get edit_user_path users(:disabled)
    assert_response :success
    assert_select 'article.message', /You are not currently assigned/
  end
end
