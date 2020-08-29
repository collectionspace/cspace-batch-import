# frozen_string_literal: true

module ApplicationHelper
  def admin?
    current_user.admin?
  end

  def allowed_access?
    current_user.enabled?
  end

  def can_edit_connection_profile?(connection)
    return false if connection.new_record? && current_user.group.profile?
    return false if connection.group&.profile?

    true
  end

  def can_edit_user_group?(user)
    current_user.admin? && !current_user.is?(user) && !user.admin?
  end

  def can_toggle_status?(record)
    if record.respond_to?(:role)
      return false if record.superuser?
      return false if current_user.is?(record)
    end

    manage?(record)
  end

  def impersonating_user?
    current_user != true_user
  end

  def manage?(record)
    current_user.manage?(record)
  end

  def spinner
    "<i class='fa fa-spinner fa-spin'></i>"
  end

  def unassigned_message
    if current_user.group.disabled?
      raw t('user.unassigned_group')
    elsif current_user.group.email
      raw t('user.unassigned_user', email: current_user.group.email)
    else
      t('user.unassigned')
    end
  end
end
