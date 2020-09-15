# frozen_string_literal: true

class Step::Policy < ApplicationPolicy
  def create?
    user.manage?(record)
  end

  def cancel?
    user.manage?(record)
  end

  def reset?
    return false unless record.cancelled? || record.failed?

    user.manage?(record)
  end

  def permitted_attributes
    []
  end
end
