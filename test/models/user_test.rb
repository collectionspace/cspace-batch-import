require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'should have the default admin user' do
    assert User.admin_created?
  end

  test 'should identify an admin user as admin' do
    user = users(:admin)
    assert user.admin?
  end

  test 'should identify a manager user as manager' do
    user = users(:manager)
    assert user.manager?
  end

  test 'should identify a member user as member' do
    user = users(:minion)
    assert user.member?
  end

  test 'can lookup a user role' do
    user = users(:minion)
    assert user.role?('Member')
  end

  test 'can identify a user as self' do
    user = users(:minion)
    assert user.is?(user)
  end

  test 'does not identify another user as self' do
    user = users(:minion)
    other = users(:outcast)
    assert_not user.is?(other)
  end

  test 'active users should be able to authenticate' do
    user = users(:minion)
    assert user.active_for_authentication?
  end

  test 'inactive users should not be able to authenticate' do
    user = users(:outcast)
    assert_not user.active_for_authentication?
  end

  # TODO: user creation group assignment via email domain
end
