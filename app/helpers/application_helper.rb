# frozen_string_literal: true

module ApplicationHelper
  def admin?
    current_user.admin?
  end

  def allowed_access?
    current_user.enabled?
  end

  def can_edit_user_group?(user)
    current_user.admin? && !current_user.is?(user) && !user.admin?
  end

  def impersonating_user?
    current_user != true_user
  end

  def manage?(record)
    current_user.manage?(record)
  end
end
