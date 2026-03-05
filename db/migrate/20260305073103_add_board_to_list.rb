class AddBoardToList < ActiveRecord::Migration[8.0]
  def change
    add_reference :lists, :board, null: false, foreign_key: true
  end
end
