require 'test_helper'

class GroupTest < ActiveSupport::TestCase
  test 'should have the default group' do
    assert Group.default_created?
  end
end
