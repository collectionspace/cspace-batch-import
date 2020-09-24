# frozen_string_literal: true

require 'application_system_test_case'

class UsersAdminCreatesGroupTest < ApplicationSystemTestCase
  setup do
    sign_in users(:admin)
  end

  test 'admin creates a group' do
    visit root_path
    click_on I18n.t('group.title.index')
    assert_selector 'h1', text: I18n.t('group.title.index')
    find('.create').click
    assert_selector 'h1', text: I18n.t('group.title.create')
    fill_in I18n.t('group.name'), with: 'TEST'
    fill_in I18n.t('group.domain'), with: 'test.com'
    fill_in I18n.t('group.email'), with: 'support@test.com'
    # fill_in I18n.t('group.profile'), with: Mapper.profile_versions.first
    click_on I18n.t('action.submit')
    assert_text I18n.t('action.created', record: 'Group')
  end
end
