require 'test_helper'

class UserTest < ActiveSupport::TestCase
  setup do
    @grp_email = 'asparagus@veg.edu' # domain matches a group (fixtures)
    @nogrp_email = 'noob@example.com' # does not match a group
    @password = 'password'
  end

  test 'should have the default superuser' do
    assert User.superuser_created?
    assert_equal User.superuser.email, User.superuser_email
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

  test 'a new user is disabled by default' do
    user = User.create(
      email: @nogrp_email, password: @password, password_confirmation: @password
    )
    assert_not user.enabled?
  end

  # Group assignment
  test 'assigns user to the default group if email domain is not matched' do
    user = User.create(
      email: @nogrp_email, password: @password, password_confirmation: @password
    )
    assert_equal user.group.name, groups(:default).name
  end

  test 'assigns user to a group when email domain matches' do
    user = User.create(
      email: @grp_email, password: @password, password_confirmation: @password
    )
    assert_equal user.group.name, groups(:veg).name
  end

  # Role assignment
  test 'assigns a new user to the default role' do
    user = User.create(
      email: @nogrp_email, password: @password, password_confirmation: @password
    )
    assert user.role?(Role.default.name)
  end
end
