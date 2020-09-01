# frozen_string_literal: true

module Step
  class Preprocess < ApplicationRecord
    belongs_to :batch
  end
end
