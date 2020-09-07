# frozen_string_literal: true

class CreateStepProcesses < ActiveRecord::Migration[6.0]
  def change
    create_table :step_processes do |t|
      t.boolean :done, null: false, default: false
      t.datetime :started_at
      t.integer :step_errors, default: 0
      t.integer :step_warnings, default: 0
      t.references :batch, null: false, foreign_key: true

      t.timestamps
    end
  end
end
