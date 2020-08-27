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
    def run_update(path, record, params, redirected_path)
      put path, params: params
      record.reload
      assert_redirected_to redirected_path
    end
  end
end

# PUNDIT
module Policy
  module TestMethods
    def assert_permit(policy, user, record, action)
      assert permit(policy, user, record, action), pundit_msg(user, record, action, true)
    end

    def refute_permit(policy, user, record, action)
      refute permit(policy, user, record, action), pundit_msg(user, record, action, false)
    end

    def permit(policy, user, record, action)
      policy.new(user, record).public_send("#{action}?")
    end

    private

    def pundit_msg(user, record, action, affirmative = true)
      msg = "User #{user.inspect} should #{affirmative ? '' : 'NOT '} be permitted to #{action} ".dup
      begin
        msg.concat record.inspect.to_s
      rescue Lockbox::DecryptionError
        msg.concat record.id.to_s
      end
    end
  end
end
