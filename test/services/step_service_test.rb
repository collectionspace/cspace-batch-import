# frozen_string_literal: true

require 'test_helper'

class StepServiceTest < ActiveSupport::TestCase
  setup do
    @s = step_preprocesses(:preprocess_superuser_batch_ready)
    @s.batch.start! # set the batch status to :pending (i.e. job enqueued)
    @step = StepService.new(step: @s, error_on_warning: false, save_to_file: false)
    @step.kickoff!
  end

  test 'can add a file to a step' do
    assert_equal 0, @step.files.size
    @step.add_file(
      Rails.root.join('test', 'fixtures', 'files', 'core-cataloging.csv'), 'csv'
    )
    assert_equal 1, @step.files.size
  end

  test 'will not add a non-file to a step' do
    assert_equal 0, @step.files.size
    @step.add_file(Rails.root.join('test/'), 'csv')
    assert_equal 0, @step.files.size
  end

  test 'will not add an unrecognized file (by type) to a step' do
    assert_equal 0, @step.files.size
    @step.add_file(Rails.root.join('README.md'), 'markdown')
    assert_equal 0, @step.files.size
  end

  test 'can add an error to a step' do
    assert_equal 0, @s.step_warnings
    @step.add_error!
    assert_equal 1, @s.step_errors
    assert_equal :failed, @s.batch.current_status
  end

  test 'can add a warning to a step (and not fail)' do
    @step.error_on_warning = false # just being clear on state
    assert_equal 0, @s.step_warnings
    @step.add_warning!
    assert_equal 1, @s.step_warnings
    assert_equal :running, @s.batch.current_status
  end

  test 'can add a warning to a step and set status to failed' do
    @step.error_on_warning = true
    @step.add_warning!
    assert_equal :failed, @s.batch.current_status
  end

  test 'can identify a cancelled step' do
    @s.batch.cancel!
    assert @step.cancelled?
  end

  test 'can cut short a step when already running' do
    assert @step.cut_short?
  end

  test 'can cut short a step when cancelled' do
    @s.batch.cancel!
    assert @step.cut_short?
  end

  test 'can complete a step, without errors is success' do
    @step.complete!
    assert @s.batch.finished?
    assert :finished, @s.batch.current_status
    assert_not_nil @s.completed_at
  end

  test 'can complete a step, with errors is a fail' do
    @step.add_error!
    @step.complete!
    assert @s.batch.failed?
    assert :failed, @s.batch.current_status
    assert_not_nil @s.completed_at
  end

  test 'can complete a step, when cancelled is cancelled' do
    @s.batch.cancel!
    @step.complete!
    assert @s.batch.cancelled?
    assert :cancelled, @s.batch.current_status
    assert_not_nil @s.completed_at
  end

  test 'can finish up after an exception' do
    @step.exception!
    assert :failed, @s.batch.current_status
    assert_not_nil @s.completed_at
  end

  test 'can kick off a step' do
    assert_equal :running, @s.batch.current_status
    assert_not_nil @s.started_at
  end

  test 'can nudge a step' do
    assert_equal 0, @s.step_num_row
    @step.nudge!
    assert_equal 1, @s.step_num_row
  end
end
