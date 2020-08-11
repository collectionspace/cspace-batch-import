# frozen_string_literal: true

class GroupsController < ApplicationController
  before_action :set_group, only: %i[update destroy]

  def index
    authorize(Group)
    @groups = policy_scope(Group).order(:name)
    @group = Group.new
  end

  def create
    respond_to do |format|
      @group = Group.new
      if @group.update_attributes(group_params)
        format.html { redirect_to groups_path, notice: t('group.created') }
      else
        format.html {
          redirect_to groups_path, alert: error_messages(@group.errors)
        }
      end
    end
  end

  def update
    respond_to do |format|
      if @group.update(group_params)
        format.html { redirect_to groups_path, notice: t('group.updated') }
      else
        format.html {
          redirect_to groups_path, alert: error_messages(@group.errors)
        }
      end
    end
  end

  private

  def set_group
    @group = authorize Group.find(params[:id])
  end

  def group_params
    params.require(:group).permit(policy(@group).permitted_attributes)
  end
end
