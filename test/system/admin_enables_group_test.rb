# frozen_string_literal: true

require 'application_system_test_case'

class AdminEnablesGroupTest < ApplicationSystemTestCase
  setup do
    sign_in users(:admin)
  end

  test 'admin enables a group' do
    visit root_path
    click_on I18n.t('group.title.index')
    assert_selector 'h1', text: I18n.t('group.title.index')
    click_on groups(:veg).name
    assert_selector 'h1', text: I18n.t('group.title.edit')
    check I18n.t('group.enabled')
    click_on I18n.t('action.submit')
    assert_text I18n.t('action.updated', record: 'Group')
  end
end
