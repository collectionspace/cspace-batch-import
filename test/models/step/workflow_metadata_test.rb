# frozen_string_literal: true

require 'test_helper'

class WorkflowMetadataTest < ActiveSupport::TestCase
  setup do
    @step = step_preprocesses(:preprocess_superuser_batch_ready)
  end

  test 'by default has no errors or warnings' do
    assert_not @step.errors?
    assert_not @step.warnings?
  end

  test 'can increment the step row count' do
    rows = @step.step_num_row
    @step.increment!
    assert_equal rows + 1, @step.step_num_row
  end

  test 'can approve a status checkin' do
    # TODO: need to replace placeholder data
    @step.update(step_num_row: 5)
    @step.batch.update(num_rows: 10)
    assert @step.checkin?
  end

  test 'can calculate the % complete' do
    # TODO: need to replace placeholder data
    @step.update(step_num_row: 7)
    @step.batch.update(num_rows: 10)
    assert_equal 70, @step.percentage_complete?
  end
end
