# frozen_string_literal: true

class ConnectionPolicy < ApplicationPolicy
  def update?
    user.owner_of?(record)
  end

  def edit?
    update?
  end

  def destroy?
    user.owner_of?(record)
  end

  def permitted_attributes_for_create
    %i[name url username password enabled primary profile user_id]
  end

  def permitted_attributes_for_update
    if user.owner_of?(record)
      %i[name url username password enabled primary profile]
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
