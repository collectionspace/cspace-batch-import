# frozen_string_literal: true

require 'test_helper'

class UsersControllerMemberTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:minion)
  end

  test 'a member can browse users' do
    assert_can_view users_path
  end

  test 'a member can access self' do
    assert_can_view edit_user_path users(:minion)
  end

  test 'a member cannot access another user' do
    refute_can_view edit_user_path users(:manager)
  end

  test 'a member cannot become another member' do
    post impersonate_user_path users(:disabled)
    refute_can_view edit_user_path users(:disabled)
  end

  test 'a member cannot de-promote a mananger' do
    user = users(:manager)
    run_update(
      user_url(user),
      user,
      { user: { role_id: roles(:member).id } }
    )
    assert_equal roles(:manager).id, user.role_id
  end
end
