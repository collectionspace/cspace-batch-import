# frozen_string_literal: true

module Step
  class Archive < ApplicationRecord
    include WorkflowMetadata
    belongs_to :batch

    def name
      :archiving
    end

    def prefix
      :arc
    end
  end
end
