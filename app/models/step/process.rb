# frozen_string_literal: true

module Step
  class Process < ApplicationRecord
    include WorkflowMetadata
    belongs_to :batch

    def check_records?
      check_records
    end

    def check_terms?
      check_terms
    end

    def name
      :processing
    end
  end
end
