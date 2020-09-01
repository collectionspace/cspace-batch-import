# frozen_string_literal: true

class Batch < ApplicationRecord
  has_one :step_preprocess, class_name: 'Step::Preprocess', dependent: :destroy
  belongs_to :user
  belongs_to :group
  validates :name, presence: true

  def preprocessed?
    # preprocess.finished? # TODO: enum
    false
  end
end
