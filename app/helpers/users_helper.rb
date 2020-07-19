# frozen_string_literal: true

module UsersHelper
  def user_is_current_user?(user)
    current_user == user
  end
end
