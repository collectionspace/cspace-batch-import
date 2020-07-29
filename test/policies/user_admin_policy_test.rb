# frozen_string_literal: true

require 'test_helper'

class UserAdminPolicyTest < ActiveSupport::TestCase
  test 'admin cannot delete another admin' do
    refute_permit UserPolicy, users(:admin), users(:admin2), :destroy
  end

  test 'admin can delete a manager' do
    assert_permit UserPolicy, users(:admin), users(:manager), :destroy
  end

  test 'admin can delete a member' do
    assert_permit UserPolicy, users(:admin), users(:minion), :destroy
  end

  test 'admin cannot delete self' do
    refute_permit UserPolicy, users(:admin), users(:admin), :destroy
  end

  test 'admin can impersonate another admin' do
    assert_permit UserPolicy, users(:admin), users(:admin2), :impersonate
  end

  test 'admin can impersonate a manager' do
    assert_permit UserPolicy, users(:admin), users(:manager), :impersonate
  end

  test 'admin can impersonate a member' do
    assert_permit UserPolicy, users(:admin), users(:minion), :impersonate
  end

  test 'admin cannot impersonate self' do
    refute_permit UserPolicy, users(:admin), users(:admin), :impersonate
  end

  test 'admin can update another admin' do
    assert_permit UserPolicy, users(:admin), users(:admin2), :update
  end

  test 'admin can update a manager' do
    assert_permit UserPolicy, users(:admin), users(:manager), :update
  end

  test 'admin can update a member' do
    assert_permit UserPolicy, users(:admin), users(:minion), :update
  end

  test 'admin can update self' do
    assert_permit UserPolicy, users(:admin), users(:admin), :update
  end
end
