# frozen_string_literal: true

require 'test_helper'

class Step::PolicyTest < ActiveSupport::TestCase
  test 'an admin can create (advance) a step' do
    assert_permit Step::Policy, users(:admin), batches(:superuser_batch), :create
  end

  test 'an admin can create (advance) a step for another group' do
    assert_permit Step::Policy, users(:admin), batches(:fishmonger_batch), :create
  end

  test 'a manager can create (advance) a step' do
    assert_permit Step::Policy, users(:manager), batches(:superuser_batch), :create
  end

  test 'a manager cannot create (advance) a step for another group' do
    refute_permit Step::Policy, users(:manager), batches(:fishmonger_batch), :create
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
end
