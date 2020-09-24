# frozen_string_literal: true

require 'application_system_test_case'

class UsersAdminCreatesConnectionTest < ApplicationSystemTestCase
  setup do
    sign_in users(:admin)
  end

  test 'admin creates a connection' do
    visit root_path
    click_on users(:admin).email
    assert_selector 'h1', text: 'Profile'
    # TODO: more
  end

  # test 'admin creates a connection with invalid data' do
  #   # TODO
  # end
end
