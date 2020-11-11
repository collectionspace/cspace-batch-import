# frozen_string_literal: true

module Step
  class Archive < ApplicationRecord
    include WorkflowMetadata
    belongs_to :batch

    def name
      :archiving
    end
  end
end
