# frozen_string_literal: true

class CreateMappers < ActiveRecord::Migration[6.0]
  def change
    create_table :mappers do |t|
      t.string :profile, null: false
      t.string :type, null: false
      t.string :url, null: false, unique: true
      t.boolean :status, null: false

      t.timestamps
    end

    add_index :mappers, %i[profile type], unique: true
  end
end
