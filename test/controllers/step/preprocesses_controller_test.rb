# frozen_string_literal: true

require 'test_helper'

module Step
  class PreprocessesControllerTest < ActionDispatch::IntegrationTest
    include ActiveJob::TestHelper

    setup do
      sign_in users(:superuser)
      @batch = batches(:superuser_batch)
      # @valid_params = {
      #   step_preprocess: {
      #     message: 'preprocess'
      #   }
      # }
    end

    test 'a user can access the new preprocess form' do
      assert_can_view(
        new_batch_step_preprocess_path(
          batches(:superuser_batch)
        )
      )
    end

    test 'should create a preprocess' do
      assert_difference('Step::Preprocess.count') do
        assert_enqueued_with(job: PreprocessJob) do
          post batch_step_preprocesses_path(@batch), params: {} # @valid_params
        end
      end

      perform_enqueued_jobs
      assert_performed_jobs 1
      assert_redirected_to batch_step_preprocess_url(@batch, Step::Preprocess.last)
    end

    test 'a user is redirected to view if the preprocess step was already run' do
      get new_batch_step_preprocess_path(batches(:superuser_batch_preprocessed))
      assert_response :redirect
    end

    test 'a user can view a preprocess' do
      assert_can_view(
        batch_step_preprocess_path(
          batches(:superuser_batch_preprocessed),
          step_preprocesses(:preprocess_superuser_batch)
        )
      )
    end

    test 'a user can cancel a preprocess' do
      s = step_preprocesses(:preprocess_superuser_batch_ready)
      s.batch.start!
      post batch_step_preprocess_cancel_path(s.batch, s)
      assert_response :redirect
      s.reload
      assert_equal :cancelled, s.batch.current_status
    end

    # TODO: reset preprocess
  end
end
