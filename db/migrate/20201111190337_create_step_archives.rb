# frozen_string_literal: true

class CreateStepArchives < ActiveRecord::Migration[6.0]
  def change
    create_table :step_archives do |t|
      t.boolean :done, null: false, default: false
      t.datetime :started_at
      t.datetime :completed_at
      t.integer :step_num_row, default: 0
      t.integer :step_errors, default: 0
      t.integer :step_warnings, default: 0
      t.json :messages, default: []
      t.references :batch, null: false, foreign_key: true

      t.timestamps
    end
  end
end
