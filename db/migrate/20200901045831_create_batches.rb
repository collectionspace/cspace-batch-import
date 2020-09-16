class CreateBatches < ActiveRecord::Migration[6.0]
  def change
    create_table :batches do |t|
      t.string :name
      t.string :job_id
      t.integer :num_rows
      t.string :step_state
      t.string :status_state
      t.references :user, null: false, foreign_key: true
      t.references :group, null: false, foreign_key: true
      t.references :connection, null: true, foreign_key: true
      t.references :mapper, null: true, foreign_key: true

      t.timestamps
    end
  end
end
