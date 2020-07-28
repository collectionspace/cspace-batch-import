# frozen_string_literal: true

module ApplicationHelper
  def allowed_access?
    current_user.admin? || (current_user.enabled? && current_user.group.enabled?)
  end

  def impersonating_user?
    current_user != true_user
  end
end
