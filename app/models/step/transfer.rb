# frozen_string_literal: true

module Step
  class Transfer < ApplicationRecord
    include WorkflowMetadata
    belongs_to :batch

    def name
      :transferring
    end

    def prefix
      :tra
    end
  end
end
