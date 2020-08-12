# frozen_string_literal: true

require 'test_helper'

class GroupTest < ActiveSupport::TestCase
  test 'should have the default group' do
    assert Group.default_created?
  end

  test 'can identify the default group' do
    assert groups(:default).default?
    assert_not groups(:fish).default?
  end

  test 'there can be only 1! (default / supergroup)' do
    group = Group.new(supergroup: true, name: 'Highlander')
    assert_not group.valid?
  end

  test 'cannot duplicate group names' do
    group = Group.new(name: 'Fish')
    assert_not group.valid?
  end

  test 'can identify a disabled group' do
    assert groups(:veg).disabled?
    assert_not groups(:veg).enabled?
  end

  test 'scope group options includes all groups for admin user' do
    %i[default fruit veg].each do |group|
      assert_includes Group.group_options(users(:admin)), Group.find_by(name: groups(group).name)
    end
  end

  test 'scope group options only includes assigned group for non-admin user' do
    assert_equal Group.group_options(users(:manager)).count, 1
    assert_includes Group.group_options(users(:manager)), Group.default
  end
end
