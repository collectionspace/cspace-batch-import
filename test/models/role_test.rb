require 'test_helper'

class RoleTest < ActiveSupport::TestCase
  test 'should have the default roles' do
    [:admin, :manager, :member].each do |role|
      assert Role.find_by(name: Role::TYPE[role])
    end
  end
end
