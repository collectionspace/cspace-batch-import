# frozen_string_literal: true

require 'application_system_test_case'

class UsersTest < ApplicationSystemTestCase
  test 'browse users as an admin' do
    sign_in users(:admin)
    visit users_url
    assert_selector 'h1', text: 'Users'
    assert_selector 'tbody tr', count: users.count
  end

  test 'browse users as a non-admin should be scoped to group' do
    %i[manager minion fishmonger salmon].each do |manager|
      sign_in users(manager)
      visit users_url
      assert_selector 'h1', text: 'Users'
      assert_selector 'tbody tr', count: users.select { |u|
        u.group.name == users(manager).group.name
      }.count
    end
  end
end
