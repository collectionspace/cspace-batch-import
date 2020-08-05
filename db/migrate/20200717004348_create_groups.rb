# frozen_string_literal: true

class CreateGroups < ActiveRecord::Migration[6.0]
  def change
    create_table :groups do |t|
      t.string :name, null: false, unique: true
      t.string :description
      t.string :domain
      t.string :email
      t.boolean :enabled, null: false, default: true

      t.timestamps
    end

    add_index :groups, :name, unique: true
  end
end
