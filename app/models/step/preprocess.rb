# frozen_string_literal: true

module Step
  class Preprocess < ApplicationRecord
    include WorkflowMetadata
    belongs_to :batch

    def name
      :preprocessing
    end

    def prefix
      :pre
    end
  end
end
