# frozen_string_literal: true

class CreateStepProcesses < ActiveRecord::Migration[6.0]
  def change
    create_table :step_processes do |t|
      t.boolean :done, null: false, default: false
      t.datetime :started_at
      t.datetime :completed_at
      t.integer :step_num_row, default: 0
      t.integer :step_errors, default: 0
      t.integer :step_warnings, default: 0
      t.references :batch, null: false, foreign_key: true

      # step specific fields
      t.boolean :check_records, null: false, default: true
      t.boolean :check_terms, null: false, default: true

      t.timestamps
    end
  end
end
