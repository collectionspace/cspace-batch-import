# frozen_string_literal: true

require 'application_system_test_case'

class AdminCreatesGroupTest < ApplicationSystemTestCase
  setup do
    sign_in users(:admin)
  end

  test 'admin creates a valid batch' do
    visit root_path
    click_on I18n.t('batch.title.index')
    assert_text I18n.t('batch.title.index')
    find('.create').click
    assert_selector 'h1', text: I18n.t('batch.title.create')
    fill_in I18n.t('batch.name'), with: 'TEST'
    select('Default', from: 'batch_group_id')
    select(connections(:core_superuser).name, from: 'batch_connection_id')
    select(mappers(:core_collectionobject_6_0).title, from: 'batch_mapper_id')
    attach_file(
      'batch_spreadsheet',
      Rails.root.join('test', 'fixtures', 'files', 'core-cataloging.csv'),
      make_visible: true
    )
    click_on I18n.t('action.submit')
    assert_text I18n.t('batch.summary')
  end
end
