# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

# PUNDIT
module Policy
  module TestMethods
    def assert_permit(policy, user, record, action)
      msg = "User #{user.inspect} should be permitted to #{action} #{record.inspect}, but isn't permitted"
      assert permit(policy, user, record, action), msg
    end

    def refute_permit(policy, user, record, action)
      msg = "User #{user.inspect} should NOT be permitted to #{action} #{record.inspect}, but is permitted"
      refute permit(policy, user, record, action), msg
    end

    def permit(policy, user, record, action)
      policy.new(user, record).public_send("#{action}?")
    end
  end
end

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  include Devise::Test::IntegrationHelpers
  include Policy::TestMethods
end
