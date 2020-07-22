# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def update?
    # user.admin? || user.manager?(record) || user.is?(record)
    user.admin? || user.is?(record)
  end

  def edit?
    update?
  end

  def destroy?
    user.admin? && !record.admin?
  end

  def impersonate?
    user.admin?
  end

  def permitted_attributes
    if user.admin? && !updating_own_record?(user, record)
      %i[active admin group_id]
    else
      %i[password password_confirmation]
    end
  end

  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.joins(:group)
             .where.not(groups: { name: Group.default_group_name })
             .where(groups: { id: user.group_id })
      end
    end
  end
end
