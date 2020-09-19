# frozen_string_literal: true

class Affiliation < ActiveRecord::Base
  belongs_to :group
  belongs_to :user
end
