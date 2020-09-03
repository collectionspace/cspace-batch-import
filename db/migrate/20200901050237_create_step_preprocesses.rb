# frozen_string_literal: true

class CreateStepPreprocesses < ActiveRecord::Migration[6.0]
  def change
    create_table :step_preprocesses do |t|
      t.boolean :done, null: false, default: false
      t.references :batch, null: false, foreign_key: true

      t.timestamps
    end
  end
end
