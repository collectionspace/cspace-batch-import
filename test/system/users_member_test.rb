# frozen_string_literal: true

require 'application_system_test_case'

class UsersMemberTest < ApplicationSystemTestCase
  setup do
    sign_in users(:salmon)
  end

  test 'browse users as a member should be scoped to group (fish)' do
    visit users_url
    assert_selector 'h1', text: 'Users'
    assert_selector 'tbody tr', count: users.select { |u|
      u.group.name == users(:salmon).group.name
    }.count

    assert_text users(:salmon).email

    # we should see but not link to users in the same group
    assert_text users(:fruit_n_veg_man).email
    assert_selector 'a', text: users(:fruit_n_veg_man).email, count: 0

    # we cannot see users from another group
    refute_text users(:admin).email
    refute_text users(:apple).email
  end

  test 'browse users as a member should be scoped to group (fruit)' do
    sign_in users(:apple)
    visit users_url
    assert_selector 'h1', text: 'Users'
    assert_selector 'tbody tr', count: users.select { |u|
      u.group.name == users(:apple).group.name
    }.count

    # we can see self
    assert_text users(:apple).email

    # but not other group's users
    refute_text users(:fruit_n_veg_man).email
    refute_text users(:admin).email
    refute_text users(:salmon).email
  end

  test 'a member can access their own accout' do
    visit root_url
    click_on users(:salmon).email
    assert_selector 'h1', text: 'Profile'
  end
end
