# frozen_string_literal: true

require 'test_helper'

class StepServiceTest < ActiveSupport::TestCase
  setup do
    @step = step_preprocesses(:preprocess_superuser_batch_ready)
    @step.batch.start! # set the batch status to :pending (i.e. job enqueued)
  end

  test 'can kick off a step' do
    assert_equal :pending, @step.batch.current_status
    step = StepService.new(step: @step, save_to_file: false)
    step.kickoff!
    assert_equal :running, @step.batch.current_status
    assert_not_nil @step.started_at
  end

  # TODO: more obviously ... outta time
end
