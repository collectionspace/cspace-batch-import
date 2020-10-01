# frozen_string_literal: true

class CreateStepTransfers < ActiveRecord::Migration[6.0]
  def change
    create_table :step_transfers do |t|
      t.boolean :done, null: false, default: false
      t.datetime :started_at
      t.datetime :completed_at
      t.integer :step_num_row, default: 0
      t.integer :step_errors, default: 0
      t.integer :step_warnings, default: 0
      t.json :messages, default: []
      t.references :batch, null: false, foreign_key: true

      # step specific fields
      t.boolean :action_create, null: false, default: false
      t.boolean :action_update, null: false, default: false
      t.boolean :action_delete, null: false, default: false

      t.timestamps
    end
  end
end
