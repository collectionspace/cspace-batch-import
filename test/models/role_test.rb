require 'test_helper'

class RoleTest < ActiveSupport::TestCase
  test 'should have the default roles' do
    [:admin, :manager, :member].each do |role|
      assert Role.find_by(name: Role::TYPE[role])
    end
  end

  test 'scope admin returns the admin role' do
    assert_equal Role.admin.name, Role::TYPE[:admin]
  end

  test 'scope manager returns the manager role' do
    assert_equal Role.manager.name, Role::TYPE[:manager]
  end

  test 'scope member returns the member role' do
    assert_equal Role.member.name, Role::TYPE[:member]
  end

  test 'scope role options includes admin role for admin user' do
    assert_includes Role.role_options(users(:admin)), Role.admin
  end

  test 'scope role options does not include admin role for non-admin user' do
    refute_includes Role.role_options(users(:manager)), Role.admin
  end
end
