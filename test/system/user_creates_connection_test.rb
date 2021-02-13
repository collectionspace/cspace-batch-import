# frozen_string_literal: true

require 'application_system_test_case'

class UserCreatesConnectionTest < ApplicationSystemTestCase
  setup do
    sign_in users(:apple)
  end

  test 'user creates a valid connection' do
    visit root_path
    # TODO: DRY admin_creates_connection_test
    click_on users(:apple).email
    assert_selector 'h1', text: I18n.t('user.title.profile')
    find('.create').click
    assert_selector 'h1', text: I18n.t('connection.title.create')
    fill_in I18n.t('connection.placeholder.name'), with: 'anthro.dev'
    fill_in I18n.t('connection.placeholder.url'), with: 'https://anthro.dev.collectionspace.org'
    fill_in I18n.t('connection.placeholder.username'), with: 'admin@anthro.dev.collectionspace.org'
    fill_in I18n.t('connection.placeholder.password'), with: 'Administrator'
    assert_text I18n.t('connection.group_has_profile')
    click_on I18n.t('action.submit')
    assert_text I18n.t('user.title.profile')
    assert_text 'anthro.dev'
  end

  # test 'user creates a connection with invalid data' do
  #   # TODO
  # end
end
