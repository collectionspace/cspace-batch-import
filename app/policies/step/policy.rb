# frozen_string_literal: true

class Step::Policy < ApplicationPolicy
  def create?
    user.manage?(record)
  end

  def destroy?
    user.manage?(record)
  end

  def permitted_attributes
    []
  end
end
