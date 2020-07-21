# frozen_string_literal: true

module ApplicationHelper
  def impersonating_user?
    current_user != true_user
  end
end
