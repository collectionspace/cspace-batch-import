require 'test_helper'

class GroupTest < ActiveSupport::TestCase
  test 'should have the default group' do
    assert Group.default_created?
  end

  test 'scope group options includes all groups for admin user' do
    [:default, :capulet, :montague].each do |group|
      assert Group.group_options(users(:admin)).include?(
        Group.find_by(name: groups(group).name)
      )
    end
  end

  test 'scope group options only includes assigned group for non-admin user' do
    assert Group.group_options(users(:manager)).count, 1
    assert Group.group_options(users(:manager)).include?(Group.default)
  end
end
