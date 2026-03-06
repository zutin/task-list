class RenameCompletedToCompletedAtOnTasks < ActiveRecord::Migration[8.0]
  def up
    add_column :tasks, :completed_at, :datetime, null: true
    Task.where(completed: true).update_all("completed_at = updated_at")
    remove_column :tasks, :completed
  end

  def down
    add_column :tasks, :completed, :boolean, default: false
    Task.where.not(completed_at: nil).update_all(completed: true)
    remove_column :tasks, :completed_at
  end
end
