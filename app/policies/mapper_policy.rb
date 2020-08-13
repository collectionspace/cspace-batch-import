# frozen_string_literal: true

class MapperPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  class Scope < Scope
    def resolve
      scope.all if user.admin?
    end
  end
end
