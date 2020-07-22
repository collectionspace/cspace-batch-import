# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def update?
    user.admin? || updating_own_record?(user, record)
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
        scope.where(id: user.id)
      end
    end
  end

  private

  def updating_own_record?(user, record)
    user.id == record.id
  end
end
