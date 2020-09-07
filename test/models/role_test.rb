# frozen_string_literal: true

require 'test_helper'

class RoleTest < ActiveSupport::TestCase
  test 'should have the default roles' do
    %i[admin manager member].each do |role|
      assert Role.find_by(name: Role::TYPE[role])
    end
  end

  test 'scope admin returns the admin role' do
    assert_equal Role::TYPE[:admin], Role.admin.name
  end

  test 'scope manager returns the manager role' do
    assert_equal Role::TYPE[:manager], Role.manager.name
  end

  test 'scope member returns the member role' do
    assert_equal Role::TYPE[:member], Role.member.name
  end

  test 'scope role options includes admin role for admin user' do
    assert_includes Role.select_options(users(:admin)), Role.admin
  end

  test 'scope role options does not include admin role for non-admin user' do
    refute_includes Role.select_options(users(:manager)), Role.admin
  end

  # MANAGE
  test 'an admin can manage any record' do
    record = Class.new(ApplicationRecord)
    assert Role::Admin.new(users(:admin)).manage?(record)
  end

  test 'an admin cannot manage nothing!' do
    assert_not Role::Admin.new(users(:admin)).manage?(nil)
  end

  test 'a manager can manage self' do
    assert Role::Manager.new(users(:manager)).manage?(users(:manager))
  end

  test 'a manager can manage another user' do
    assert Role::Manager.new(users(:manager)).manage?(users(:outcast))
  end

  test 'a manager can manage their own group' do
    assert Role::Manager.new(users(:manager)).manage?(groups(:default))
  end

  test 'a manager cannot manage another group' do
    assert_not Role::Manager.new(users(:manager)).manage?(groups(:fish))
  end

  test 'a manager can manage their own batch' do
    assert Role::Manager.new(users(:fishmonger)).manage?(batches(:fishmonger_batch))
  end

  test "a manager can manage their member's batch" do
    assert Role::Manager.new(users(:fishmonger)).manage?(batches(:tuna_batch))
  end

  test "a manager cannot manage another group member's batch" do
    assert_not Role::Manager.new(users(:fishmonger)).manage?(batches(:minion_batch))
  end

  test 'a member can manage self' do
    assert Role::Member.new(users(:minion)).manage?(users(:minion))
  end

  test 'a member cannot manage another user' do
    assert_not Role::Member.new(users(:minion)).manage?(users(:outcast))
  end

  test 'a member can manage their own batch' do
    assert Role::Member.new(users(:minion)).manage?(batches(:minion_batch))
  end

  test "a member cannot manage another user's batch" do
    assert_not Role::Member.new(users(:minion)).manage?(batches(:superuser_batch))
  end
end
