# frozen_string_literal: true

require 'test_helper'

class Step::PreprocessTest < ActiveSupport::TestCase
  setup do
    @params = {
      batch_id: batches(:superuser_default_batch).id
    }
  end

  test 'cannot create a preprocess step without a batch' do
    @params.delete(:batch_id)
    refute Step::Preprocess.new(@params).valid?
  end

  test 'can create a preprocess step with valid params' do
    assert Step::Preprocess.new(@params).valid?
  end
end