# frozen_string_literal: true

class MappersController < ApplicationController
  def index
    authorize(Mapper)
    @mappers = policy_scope(Mapper).order(
      'mappers.profile asc, mappers.version asc, mappers.type asc'
    )
  end

  # OTHER

  def autocomplete
    authorize(Mapper)
    results = Mapper.mapper_profiles.find_all do |mp|
      mp.starts_with?(params[:query])
    end

    render json: results.map { |mp| { value: mp } }
  end
end
