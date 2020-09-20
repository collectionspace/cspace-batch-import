# frozen_string_literal: true

require 'application_system_test_case'

class UsersTest < ApplicationSystemTestCase
  test 'non-admin user in the default group does not have access' do
    sign_in users(:manager)
    visit users_url
    assert_selector 'article', text: 'You are not'
  end

  test 'a disabled groups user does not have access' do
    sign_in users(:brocolli)
    visit users_url
    assert_selector 'article', text: 'Your group is disabled'
  end

  test 'a disabled user does not have access' do
    sign_in users(:banana)
    visit users_url
    assert_selector 'article', text: 'You are not currently enabled'
  end

  test 'an inactive user cannot login' do
    sign_in users(:outcast)
    visit users_url
    assert_selector 'h2', text: 'Log in'
  end
end
