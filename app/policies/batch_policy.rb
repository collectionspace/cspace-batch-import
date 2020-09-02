# frozen_string_literal: true

class BatchPolicy < ApplicationPolicy
  def show?
    user.manage?(record)
  end

  def create?
    true
  end

  def new?
    create?
  end

  def destroy?
    user.manage?(record)
  end

  def permitted_attributes
    # TODO
  end

  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        user.group.batches
      end
    end
  end
end
