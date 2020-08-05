# frozen_string_literal: true

class GroupPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def create?
    user.admin?
  end

  def update?
    user.admin?
  end

  def edit?
    update?
  end

  def destroy?
    return false if record == Group.default

    user.admin?
  end

  def permitted_attributes
    if user.admin? && record == Group.default
      %i[description domain email]
    elsif user.admin?
      %i[name description domain email enabled]
    else
      []
    end
  end

  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(id: user.group_id)
      end
    end
  end
end
