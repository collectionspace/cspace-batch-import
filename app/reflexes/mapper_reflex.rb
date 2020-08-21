# frozen_string_literal: true

class MapperReflex < ApplicationReflex
  def refresh
    Mapper.refresh
  end
end
