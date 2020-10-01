require 'test_helper'

module Step
  class TransferTest < ActiveSupport::TestCase
    setup do
      @params = {
        batch_id: batches(:superuser_batch).id
      }
    end

    test 'cannot create a transfer step without a batch' do
      @params.delete(:batch_id)
      refute Step::Transfer.new(@params).valid?
    end

    # TODO: make this conditional validation on batch state
    test 'can create a transfer step with valid params' do
      assert Step::Transfer.new(@params).valid?
    end
  end
end
