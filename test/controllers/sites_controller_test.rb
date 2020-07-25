# frozen_string_literal: true

require 'test_helper'

class SitesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:admin)
  end

  test 'redirected if not logged in' do
    sign_out :user
    get root_path
    assert_response :redirect
  end

  test 'can get users' do
    get users_path
    assert_response :success
  end
end
