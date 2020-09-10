# frozen_string_literal: true

class GroupsController < ApplicationController
  before_action :set_group, only: %i[edit update destroy]

  def index
    authorize(Group)
    @groups = policy_scope(Group).order(:name)
  end

  def new
    @group = Group.new
  end

  def create
    respond_to do |format|
      @group = Group.new
      if @group.update(group_params)
        format.html { redirect_to groups_path, notice: t('group.created') }
      else
        format.html { render :new }
      end
    end
  end

  def edit; end

  def update
    respond_to do |format|
      if @group.update(group_params)
        format.html { redirect_to edit_group_path(@group), notice: t('group.updated') }
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    @group.destroy
    respond_to do |format|
      format.html { redirect_to groups_url, notice: t('group.deleted') }
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
