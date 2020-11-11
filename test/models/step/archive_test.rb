require 'test_helper'

module Step
  class ArchiveTest < ActiveSupport::TestCase
    setup do
      @params = {
        batch_id: batches(:superuser_batch).id
      }
    end

    test 'cannot create an archive step without a batch' do
      @params.delete(:batch_id)
      refute Step::Archive.new(@params).valid?
    end

    # TODO: make this conditional validation on batch state
    test 'can create an archive step with valid params' do
      assert Step::Archive.new(@params).valid?
    end
  end
end
