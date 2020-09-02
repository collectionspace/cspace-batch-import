# frozen_string_literal: true

require 'test_helper'

class Steps::PreprocessesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:superuser)
    @new_batch = batches(:superuser_default_batch_no_steps)
    # @valid_params = {
    #   step_preprocess: {
    #     message: 'preprocess'
    #   }
    # }
  end

  test 'a user can access the new preprocess form' do
    assert_can_view(
      new_batch_steps_preprocess_path(
        batches(:superuser_default_batch_no_steps)
      )
    )
  end

  test 'a user is redirected to view if the preprocess step was already run' do
    get new_batch_steps_preprocess_path(batches(:superuser_default_batch))
    assert_response :redirect
  end

  test 'a user can view a preprocess' do
    assert_can_view(
      batch_steps_preprocess_path(
        batches(:superuser_default_batch),
        step_preprocesses(:preprocess_superuser_default_batch)
      )
    )
  end

  test 'should create a preprocess' do
    assert_difference('Step::Preprocess.count') do
      post batch_steps_preprocesses_path(@new_batch), params: {} # @valid_params
    end

    assert_redirected_to batch_steps_preprocess_url(@new_batch, Step::Preprocess.last)
  end
end
