# frozen_string_literal: true

class MappersController < ApplicationController
  def index
    authorize(Mapper)
    @mappers = policy_scope(Mapper).order('mappers.profile asc, mappers.type asc')
  end
end
