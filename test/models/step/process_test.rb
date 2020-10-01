require 'test_helper'

module Step
  class ProcessTest < ActiveSupport::TestCase
    setup do
      @params = {
        batch_id: batches(:superuser_batch).id
      }
    end

    test 'cannot create a process step without a batch' do
      @params.delete(:batch_id)
      refute Step::Process.new(@params).valid?
    end

    # TODO: make this conditional validation on batch state
    test 'can create a process step with valid params' do
      assert Step::Process.new(@params).valid?
    end
  end
end
