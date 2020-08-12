# frozen_string_literal: true

# INTEGRATION
module Integration
  module TestMethods
    # INDEX
    def assert_can_view(path)
      get path
      assert_response :success
    end

    def refute_can_view(path)
      get path
      assert_response :redirect
      follow_redirect!
      assert_select 'p.flash', /You are not authorized/
    end

    # CREATE
    def assert_can_create(path, model, params, redirect_path)
      assert_difference("#{model}.count") do
        post path, params: params
      end
      assert_redirected_to redirect_path
    end

    def refute_can_create(path, model, params, redirect_path)
      assert_no_difference("#{model}.count") do
        post path, params: params
      end
      assert_redirected_to redirect_path
    end

    # DELETE
    # EDIT

    # UPDATE
    def assert_can_update(path, record, params, field, value, redirected_path)
      put path, params: params
      record.reload
      assert_equal value, record.send(field)
      assert_redirected_to redirected_path
    end

    def refute_can_update(path, record, params, field, value, redirected_path)
      put path, params: params
      record.reload
      assert_not_equal value, record.send(field)
      assert_redirected_to redirected_path
    end
  end
end

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