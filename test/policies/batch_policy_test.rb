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

  test 'an admin can view a batch belonging to any group' do
    assert_permit BatchPolicy, users(:admin), batches(:fishmonger_batch), :show
  end

  test 'a manager can view a batch belonging to their group' do
    assert_permit BatchPolicy, users(:manager), batches(:minion_batch), :show
  end

  test 'a manager cannot view a batch belonging to another group' do
    refute_permit BatchPolicy, users(:manager), batches(:fishmonger_batch), :show
  end

  test 'a member can view a batch belonging to their group' do
    assert_permit BatchPolicy, users(:minion), batches(:superuser_batch), :show
  end

  test 'a member cannot view a batch belonging to another group' do
    refute_permit BatchPolicy, users(:minion), batches(:fishmonger_batch), :show
  end

  test 'admin can delete a batch' do
    assert_permit BatchPolicy, users(:admin), batches(:superuser_batch), :destroy
  end

  test 'a manager can delete a batch' do
    assert_permit BatchPolicy, users(:manager), batches(:superuser_batch), :destroy
  end

  test "a manager cannot delete another group's batch" do
    refute_permit BatchPolicy, users(:manager), batches(:fishmonger_batch), :destroy
  end

  test 'a member can delete their own batch' do
    assert_permit BatchPolicy, users(:minion), batches(:minion_batch), :destroy
  end

  test "a member cannot delete another user's batch" do
    assert_permit BatchPolicy, users(:manager), batches(:superuser_batch), :destroy
  end

  test 'a queued batch cannot be deleted' do
    batch = batches(:superuser_batch)
    batch.start!
    refute_permit BatchPolicy, users(:superuser), batch, :destroy
  end

  test 'a running batch cannot be deleted' do
    batch = batches(:superuser_batch)
    batch.start!
    batch.run!
    refute_permit BatchPolicy, users(:superuser), batch, :destroy
  end
end
