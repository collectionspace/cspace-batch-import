# frozen_string_literal: true

require 'test_helper'

module Step
  class TransfersControllerTest < ActionDispatch::IntegrationTest
    setup do
      sign_in users(:superuser)
      @batch = batches(:superuser_batch) # generic batch for create
      @batch_ready = batches(:superuser_batch_processed) # transition from
      @batch_transferred = batches(:superuser_batch_transferred) # step finished
      @batch_transferred_step = step_transfers(:transfer_superuser_batch)
      @params = { action_create: true, action_update: true }
    end

    test 'a user can access the new transfer form' do
      # we transition from the previous step to this one
      assert_can_view(new_batch_step_transfer_path(@batch_ready))
    end

    test 'should create a transfer' do
      # TODO: with job
      assert_difference('Step::Transfer.count') do
        post batch_step_transfers_path(@batch), params: { step_transfer: @params }
      end

      step = Step::Transfer.last
      assert_redirected_to batch_step_transfer_url(@batch, step)
      assert step.action_create?
      assert step.action_update?
    end

    test 'a user is redirected to view if the transfer step was already run' do
      get new_batch_step_transfer_path(@batch_transferred)
      assert_response :redirect
    end

    test 'a user can view a transfer' do
      assert_can_view(
        batch_step_transfer_path(@batch_transferred, @batch_transferred_step)
      )
    end

    test 'a user can cancel a transfer' do
      step = step_transfers(:transfer_superuser_batch_ready)
      step.batch.start!
      post batch_step_transfer_cancel_path(step.batch, step)
      assert_response :redirect
      step.reload
      assert_equal :cancelled, step.batch.current_status
    end

    test 'a user can reset a transfer' do
      step = step_transfers(:transfer_superuser_batch_ready)
      step.batch.start!
      step.batch.run!
      step.batch.failed!
      assert_difference('Step::Transfer.count', -1) do
        post batch_step_transfer_reset_path(step.batch, step)
      end
      assert_response :redirect
    end
  end
end
