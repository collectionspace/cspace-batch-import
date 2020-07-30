# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def update?
    return false if record == User.superuser && !user.is?(record)
    return false if record.admin? && !user.admin?

    user.admin? || user.manage?(record) || user.is?(record)
  end

  def edit?
    update?
  end

  def destroy?
    return false if record == User.superuser

    user.admin? && !user.is?(record)
  end

  def impersonate?
    return false if user.is?(record)

    user.admin? || (!record.admin? && user.manage?(record))
  end

  def permitted_attributes
    if user.admin? && !user.is?(record)
      %i[active enabled group_id role_id]
    elsif user.manage?(record) && !user.is?(record)
      %i[active enabled role_id]
    else
      %i[password password_confirmation]
    end
  end

  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.joins(:group).where(groups: { id: user.group_id })
      end
    end
  end
end
