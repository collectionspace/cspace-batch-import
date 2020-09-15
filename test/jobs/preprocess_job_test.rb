require 'test_helper'

class PreprocessJobTest < ActiveJob::TestCase
  setup do
    @preprocess = step_preprocesses(:preprocess_superuser_batch_ready) # ready to go!
    @preprocess.batch.start! # put the job into pending status (required transition)
  end

  test "finishes the job" do
    assert @preprocess.batch.pending?
    PreprocessJob.perform_now(@preprocess)
    assert_equal :finished, @preprocess.batch.current_status
  end
end
