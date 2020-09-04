# frozen_string_literal: true

require 'test_helper'

class BatchPolicyTest < ActiveSupport::TestCase
  test 'admin is allowed to create a batch' do
    assert_permit BatchPolicy, users(:admin), Batch.new, :new
  end

  test 'manager is allowed to create a batch' do
    assert_permit BatchPolicy, users(:manager), Batch.new, :new
  end

  test 'member is allowed to create a batch' do
    assert_permit BatchPolicy, users(:minion), Batch.new, :new
  end

  test 'a user cannot create a batch if they have no connections' do
    refute_permit BatchPolicy, users(:fishmonger), Batch.new, :new
  end

  test 'a user can create a batch' do
    assert_permit BatchPolicy, users(:minion), Batch.new, :create
  end

  test 'admin can delete a batch' do
    assert_permit BatchPolicy, users(:admin), batches(:superuser_default_batch), :destroy
  end

  test 'a manager can delete a batch' do
    assert_permit BatchPolicy, users(:manager), batches(:superuser_default_batch), :destroy
  end

  test "a manager cannot delete another group's batch" do
    refute_permit BatchPolicy, users(:manager), batches(:fishmonger_fish_batch), :destroy
  end

  test 'a member can delete their own batch' do
    assert_permit BatchPolicy, users(:minion), batches(:minion_default_batch), :destroy
  end

  test "a member cannot delete another user's batch" do
    assert_permit BatchPolicy, users(:manager), batches(:superuser_default_batch), :destroy
  end
end
