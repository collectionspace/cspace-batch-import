# frozen_string_literal: true

require 'test_helper'

class UsersControllerAdminTest < ActionDispatch::IntegrationTest
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

  # DISABLED USER
  test 'a disabled user can sign in' do
    sign_in users(:disabled)
    get root_path
    assert_response :success
    assert_select 'article.message', /You are not currently enabled/
  end

  test 'a disabled user cannot update self' do
    sign_in users(:disabled)
    get edit_user_path users(:disabled)
    assert_response :success
    assert_select 'article.message', /You are not currently enabled/
  end
end
