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

  def csv_content_types
    [
      'application/vnd.ms-excel',
      'text/csv'
    ].join(',')
  end

  def current_step_path(batch)
    step_state = batch.aasm(:step).human_state.to_sym
    step_state = :preprocess if step_state == :new
    send("new_batch_step_#{step_state}_path", batch)
  end

  def filename_js
    filename_target = 'document.getElementById("file-name").textContent'
    filename_value = 'document.getElementById("batch_spreadsheet").value'
    filename_transform = 'replace("C:\\\\fakepath\\\\", "")'
    "#{filename_target} = #{filename_value}.#{filename_transform}"
  end

  def status_color(status)
    case status
    when :ready
      'primary'
    when :pending
      'info'
    when :running
      'dark'
    when :cancelled
      'warning'
    when :finished
      'success'
    when :failed
      'danger'
    end
  end

  def status_icon(status)
    case status
    when :ready
      'plus'
    when :pending
      'pause'
    when :running
      'refresh spin'
    when :cancelled
      'exclamation-circle'
    when :finished
      'thumbs-up'
    when :failed
      'exclamation-triangle'
    end
  end

  def impersonating_user?
    current_user != true_user
  end

  def manage?(record)
    current_user.manage?(record)
  end

  def spinner_html
    "<i class='fa fa-spinner fa-spin'></i>"
  end

  def spinner_js
    'this.querySelector(".fa-refresh").classList.add("fa-spin");'
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

  def waiting_to_start_html
    '<span class="is-italic">not started</span>'
  end
end
