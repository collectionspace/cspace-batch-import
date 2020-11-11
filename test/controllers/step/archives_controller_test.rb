# frozen_string_literal: true

require 'test_helper'

module Step
  class ArchivesControllerTest < ActionDispatch::IntegrationTest
    setup do
      sign_in users(:superuser)
      @batch = batches(:superuser_batch) # generic batch for create
      @batch_ready = batches(:superuser_batch_transferred) # transition from
      @batch_archived = batches(:superuser_batch_archived) # step finished
      @batch_archived_step = step_archives(:archive_superuser_batch)
      @params = {}
    end

    test 'a user can access the new archive form' do
      # we transition from the previous step to this one
      assert_can_view(new_batch_step_archive_path(@batch_ready))
    end

    test 'should create an archive' do
      # TODO: with job
      assert_difference('Step::Archive.count') do
        post batch_step_archives_path(@batch), params: { step_archive: @params }
      end

      step = Step::Archive.last
      assert_redirected_to batch_step_archive_url(@batch, step)
    end

    test 'a user is redirected to view if the archive step was already run' do
      get new_batch_step_archive_path(@batch_archived)
      assert_response :redirect
    end

    test 'a user can view an archive' do
      assert_can_view(
        batch_step_archive_path(@batch_archived, @batch_archived_step)
      )
    end

    test 'a user can cancel an archive' do
      step = step_archives(:archive_superuser_batch_ready)
      step.batch.start!
      post batch_step_archive_cancel_path(step.batch, step)
      assert_response :redirect
      step.reload
      assert_equal :cancelled, step.batch.current_status
    end

    test 'a user can reset an archive' do
      step = step_archives(:archive_superuser_batch_ready)
      step.batch.start!
      step.batch.run!
      step.batch.failed!
      assert_difference('Step::Archive.count', -1) do
        post batch_step_archive_reset_path(step.batch, step)
      end
      assert_response :redirect
    end
  end
end
