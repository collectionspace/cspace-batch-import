# frozen_string_literal: true

class ConnectionPolicy < ApplicationPolicy
  def create?
    user.enabled?
  end

  def update?
    user.manage?(record)
  end

  def edit?
    update?
  end

  def destroy?
    user.manage?(record)
  end

  def permitted_attributes
    if user.manage?(record)
      %i[url username password enabled primary profile user_id]
    else
      []
    end
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
