class CreateLists < ActiveRecord::Migration[8.0]
  def change
    create_table :lists do |t|
      t.string :name, null: false
      t.integer :position, default: 1, null: false

      t.timestamps
    end
  end
end
