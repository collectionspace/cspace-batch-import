require 'test_helper'

class GroupTest < ActiveSupport::TestCase
  test 'should have the default group' do
    assert Group.default_created?
    assert_equal Group.default.name, Group.default_group_name
  end

  test 'scope group options includes all groups for admin user' do
    [:default, :capulet, :montague].each do |group|
      assert_includes Group.group_options(users(:admin)), Group.find_by(name: groups(group).name)
    end
  end

  test 'scope group options only includes assigned group for non-admin user' do
    assert_equal Group.group_options(users(:manager)).count, 1
    assert_includes Group.group_options(users(:manager)), Group.default
  end
end
