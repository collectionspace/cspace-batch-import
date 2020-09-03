# frozen_string_literal: true

class Batch < ApplicationRecord
  include WorkflowManager
  has_one :step_preprocess, class_name: 'Step::Preprocess', dependent: :destroy
  belongs_to :user
  belongs_to :group
  validates :name, presence: true
end
