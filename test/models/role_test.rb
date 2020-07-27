require 'test_helper'

class RoleTest < ActiveSupport::TestCase
  test 'should have the default roles' do
    [:admin, :manager, :member].each do |role|
      assert Role.find_by(name: Role::TYPE[role])
    end
  end

  test 'scope role options includes admin role for admin user' do
    assert Role.role_options(users(:admin)).include?(Role.admin)
  end

  test 'scope role options does not include admin role for non-admin user' do
    assert_not Role.role_options(users(:manager)).include?(Role.admin)
  end
end
