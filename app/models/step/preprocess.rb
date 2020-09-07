# frozen_string_literal: true

module Step
  class Preprocess < ApplicationRecord
    belongs_to :batch

    def done?
      done
    end

    def name
      :preprocessing
    end
  end
end
