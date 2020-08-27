# frozen_string_literal: true

require 'test_helper'

class ConnectionPolicyTest < ActiveSupport::TestCase
  test 'admin can create a connection for self' do
    assert_permit ConnectionPolicy, users(:admin), Connection.new, :create
  end

  test 'manager can create a connection for self' do
    assert_permit ConnectionPolicy, users(:manager), Connection.new, :create
  end

  test 'member can create a connection for self' do
    assert_permit ConnectionPolicy, users(:minion), Connection.new, :create
  end

  test 'admin can update a connection' do
    assert_permit ConnectionPolicy, users(:admin), connections(:core_manager), :update
  end

  test 'manager can update owned connection' do
    assert_permit ConnectionPolicy, users(:manager), connections(:core_manager), :update
  end

  test 'manager can update group user connection' do
    assert_permit ConnectionPolicy, users(:manager), connections(:core_minion), :update
  end

  test "manager cannot update another group user's connection" do
    refute_permit ConnectionPolicy, users(:manager), connections(:core_salmon), :update
  end

  test 'member can update owned connection' do
    assert_permit ConnectionPolicy, users(:minion), connections(:core_minion), :update
  end

  test "member cannot update another user's connection" do
    refute_permit ConnectionPolicy, users(:minion), connections(:core_manager), :update
  end

  test 'admin can delete a connection' do
    assert_permit ConnectionPolicy, users(:admin), connections(:core_manager), :destroy
  end

  test 'manager can delete owned connection' do
    assert_permit ConnectionPolicy, users(:manager), connections(:core_manager), :destroy
  end

  test 'manager can delete group user connection' do
    assert_permit ConnectionPolicy, users(:manager), connections(:core_minion), :destroy
  end

  test "manager cannot delete another group user's connection" do
    refute_permit ConnectionPolicy, users(:manager), connections(:core_salmon), :destroy
  end

  test 'member can delete owned connection' do
    assert_permit ConnectionPolicy, users(:minion), connections(:core_minion), :destroy
  end

  test "member cannot delete another user's connection" do
    refute_permit ConnectionPolicy, users(:minion), connections(:core_manager), :destroy
  end
end
