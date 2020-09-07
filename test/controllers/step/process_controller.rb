# frozen_string_literal: true

require 'test_helper'

module Step
  class ProcessesControllerTest < ActionDispatch::IntegrationTest
    setup do
      sign_in users(:superuser)
      @batch = batches(:superuser_batch_processing)
    end

    test 'a user can access the new process form' do
      assert_can_view(
        new_batch_step_process_path(
          batches(:superuser_batch_processing)
        )
      )
    end

    test 'should create a process' do
      assert_difference('Step::Process.count') do
        post batch_step_processes_path(@batch), params: {}
      end

      assert_redirected_to batch_step_process_url(@batch, Step::Process.last)
    end

    test 'a user is redirected to view if the process step was already run' do
      get new_batch_step_process_path(batches(:superuser_batch_processed))
      assert_response :redirect
    end

    test 'a user can view a process' do
      assert_can_view(
        batch_step_process_path(
          batches(:superuser_batch_processed),
          step_processes(:process_superuser_batch)
        )
      )
    end
  end
end
