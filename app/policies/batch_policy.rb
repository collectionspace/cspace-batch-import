# frozen_string_literal: true

class BatchPolicy < ApplicationPolicy
  # only display the batch if [manage] or the user's group matches the batch's group
  def show?
    user.manage?(record) || user.group?(record.group)
  end

  # any user can create a batch (we check group integrity in the controller)
  def create?
    true
  end

  # a user must have an enabled connection to access the batch create form
  def new?
    user.connections.where(enabled: true).count.positive?
  end

  def destroy?
    # don't allow queued / running batches to be destroyed
    return false if record.pending? || record.running?

    user.manage?(record)
  end

  def permitted_attributes
    %i[name spreadsheet group_id connection_id mapper_id]
  end

  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        # all batches in the user's group
        user.group.batches
      end
    end
  end
end
