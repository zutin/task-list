class AddPerformanceIndexes < ActiveRecord::Migration[8.0]
  def change
    remove_index :tasks, :list_id
    add_index :tasks, [ :list_id, :position ]

    add_index :tasks, :completed_at

    add_index :tasks, :due_at

    remove_index :lists, :board_id
    add_index :lists, [ :board_id, :position ]

    add_index :boards, [ :updated_at, :name ]
  end
end
