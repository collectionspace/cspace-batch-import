# frozen_string_literal: true

class CreateAffiliations < ActiveRecord::Migration[6.0]
  def change
    create_table :affiliations do |t|
      t.belongs_to :group
      t.belongs_to :user
    end
    add_index :affiliations, %i[group_id user_id], unique: true
  end
end
