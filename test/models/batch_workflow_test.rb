# frozen_string_literal: true

require 'test_helper'

class BatchWorkflowTest < ActiveSupport::TestCase
  setup do
    @batch = batches(:superuser_batch)
  end

  def run_steps_cancel
    @batch.start!
    @batch.run!
    @batch.cancel!
  end

  def run_steps_fail
    @batch.start!
    @batch.run!
    @batch.failed!
  end

  def run_steps_success
    @batch.start!
    @batch.run!
    @batch.finished!
  end

  def transition_to(to:, from:, event:, next_step: :nil)
    assert_transitions_from @batch, from, to: to, on_event: event, on: :step
    refute_transition_to_allowed @batch, next_step, on: :step
    assert_have_state @batch, :ready, on: :status
  end

  def transition_to_preprocessing
    transition_to(
      to: :preprocessing, from: :new, event: :preprocess, next_step: :process
    )
  end

  def transition_to_processing
    transition_to(
      to: :processing, from: :preprocessing, event: :process, next_step: :transfer
    )
  end

  test 'a new batch has the default (post create) workflow state' do
    assert_have_state @batch, :preprocessing, on: :step
    assert_have_state @batch, :ready, on: :status
    refute @batch.ran?
  end

  test 'can transition to preprocessing' do
    transition_to_preprocessing
    assert :preprocessing, @batch.current_step
    assert @batch.current_step?(:preprocessing)
    refute @batch.ran?
  end

  test 'can transition to processing if status steps succeed' do
    transition_to_preprocessing
    run_steps_success
    assert :finished, @batch.current_status
    assert @batch.ran?
    assert_transition_to_allowed @batch, :processing, on: :step
    transition_to_processing
    assert_have_state @batch, :processing, on: :step
    assert_have_state @batch, :ready, on: :status
  end

  test 'cannot transition to processing if status steps fail' do
    transition_to_preprocessing
    run_steps_fail
    assert :failed, @batch.current_status
    assert @batch.ran?
    refute_transition_to_allowed @batch, :processing, on: :step
    assert_have_state @batch, :failed, on: :status
    @batch.retry!
    assert_have_state @batch, :ready, on: :status
  end

  test 'cannot transition to processing if status cancelled' do
    transition_to_preprocessing
    run_steps_cancel
    assert :cancelled, @batch.current_status
    assert @batch.ran?
    refute_transition_to_allowed @batch, :processing, on: :step
    assert_have_state @batch, :cancelled, on: :status
    @batch.retry!
    assert_have_state @batch, :ready, on: :status
  end

  # TODO: remaining workflow
end
