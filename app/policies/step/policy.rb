# frozen_string_literal: true

class Step::Policy < ApplicationPolicy
  def create?
    user.manage?(record)
  end

  def cancel?
    return false unless record.can_cancel?

    user.manage?(record)
  end

  def reset?
    return false unless record.can_reset?

    user.manage?(record)
  end

  def permitted_attributes
    []
  end
end
