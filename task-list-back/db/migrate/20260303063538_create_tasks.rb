class CreateTasks < ActiveRecord::Migration[8.0]
  def change
    create_table :tasks do |t|
      t.string :title, null: false
      t.string :description
      t.datetime :due_at
      t.boolean :completed, default: false

      t.timestamps
    end
  end
end
