# frozen_string_literal: true

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  setup do
    @password = 'password'
  end

  test 'should have the default superuser' do
    assert User.superuser_created?
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
      email: 'example@example.com',
      password: @password,
      password_confirmation: @password
    )
    assert_not user.enabled?
  end

  # Group assignment
  test 'assigns user to the default group if email domain is not matched' do
    user = User.create(
      email: 'example@example.com',
      password: @password,
      password_confirmation: @password
    )
    assert_equal user.group.name, groups(:default).name
  end

  test 'assigns user to a group when email domain matches' do
    user = User.create(
      email: 'asparagus@veg.edu', # matches group from fixtures
      password: @password,
      password_confirmation: @password
    )
    assert_equal user.group.name, groups(:veg).name
  end

  # Role assignment
  test 'assigns a new user to the default role' do
    user = User.create(
      email: 'example@example.com',
      password: @password,
      password_confirmation: @password
    )
    assert user.role?(Role.default.name)
  end

  # New group assignment
  test 'assigns first user of group as manager and subsequent users as member' do
    group = Group.create(name: 'Example', domain: 'example.org')
    manager = User.create(
      email: 'manager@example.org',
      password: @password,
      password_confirmation: @password,
      group: group
    )
    member = User.create(
      email: 'member@example.org',
      password: @password,
      password_confirmation: @password,
      group: group
    )
    assert manager.role?(Role.manager.name)
    assert manager.enabled?
    assert member.role?(Role.member.name)
    assert_not member.enabled?
  end
end
