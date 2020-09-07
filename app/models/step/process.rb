# frozen_string_literal: true

module Step
  class Process < ApplicationRecord
    belongs_to :batch

    def done?
      done
    end

    def name
      :processing
    end
  end
end
