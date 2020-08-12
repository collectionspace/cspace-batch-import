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
    follow_redirect!
    assert_select 'p.flash', 'You need to sign in or sign up before continuing.'
  end

  test 'can get the home page' do
    get root_path
    assert_response :success
  end
end
