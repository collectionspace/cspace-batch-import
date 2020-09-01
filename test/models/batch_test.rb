require 'test_helper'

class BatchTest < ActiveSupport::TestCase
  setup do
    @params = {
      name: 'batch1',
      user_id: users(:superuser).id,
      group_id: users(:superuser).group.id
    }
  end

  test 'cannot create batch without a name' do
    @params.delete(:name)
    refute Batch.new(@params).valid?
  end

  test 'cannot create batch without a user' do
    @params.delete(:user_id)
    refute Batch.new(@params).valid?
  end

  test 'cannot create batch without a group' do
    @params.delete(:group_id)
    refute Batch.new(@params).valid?
  end

  test 'can create a batch with valid params' do
    assert Batch.new(@params).valid?
  end
end
