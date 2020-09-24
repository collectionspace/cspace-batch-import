# frozen_string_literal: true

require 'test_helper'

class Step::PolicyTest < ActiveSupport::TestCase
  test 'an admin can create (advance) a step' do
    assert_permit Step::Policy, users(:admin), batches(:superuser_batch), :create
  end

  test 'an admin can create (advance) a step for another group' do
    assert_permit Step::Policy, users(:admin), batches(:fishmonger_batch), :create
  end

  test 'an admin can cancel a step' do
    batch = batches(:superuser_batch)
    batch.start!
    batch.cancel!
    assert_permit Step::Policy, users(:admin), batch, :reset
  end

  test 'an admin can reset a step' do
    batch = batches(:superuser_batch)
    batch.start!
    assert_permit Step::Policy, users(:admin), batch, :cancel
  end

  test 'a manager can create (advance) a step' do
    assert_permit Step::Policy, users(:manager), batches(:superuser_batch), :create
  end

  test 'a manager cannot create (advance) a step for another group' do
    refute_permit Step::Policy, users(:manager), batches(:fishmonger_batch), :create
  end

  test 'a manager can cancel a step' do
    batch = batches(:superuser_batch)
    batch.start!
    assert_permit Step::Policy, users(:manager), batch, :cancel
  end

  test 'a manager can reset a step' do
    batch = batches(:superuser_batch)
    batch.start!
    batch.run!
    batch.failed!
    assert_permit Step::Policy, users(:manager), batch, :reset
  end

  test 'a member can create (advance) a step for a batch they own' do
    assert_permit Step::Policy, users(:minion), batches(:minion_batch), :create
  end

  test 'a member cannot create (advance) a step for a batch they did not create' do
    refute_permit Step::Policy, users(:minion), batches(:superuser_batch), :create
  end

  test 'a member cannot create (advance) a step for another group' do
    refute_permit Step::Policy, users(:minion), batches(:fishmonger_batch), :create
  end

  test 'a member can cancel a step for a batch they own' do
    batch = batches(:minion_batch)
    batch.start!
    assert_permit Step::Policy, users(:minion), batch, :cancel
  end

  test 'a member cannot cancel a step for another user' do
    batch = batches(:superuser_batch)
    batch.start!
    refute_permit Step::Policy, users(:minion), batch, :cancel
  end

  test 'a member can reset a step for a batch they own' do
    batch = batches(:minion_batch)
    batch.start!
    batch.run!
    batch.failed!
    assert_permit Step::Policy, users(:minion), batch, :reset
  end

  test 'a member cannot reset a step for another user' do
    batch = batches(:superuser_batch)
    batch.start!
    batch.run!
    batch.failed!
    refute_permit Step::Policy, users(:minion), batch, :reset
  end
end
