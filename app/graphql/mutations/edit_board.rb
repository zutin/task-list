module Mutations
  class EditBoard < BaseMutation
    argument :id, ID, required: true
    argument :name, String, required: false
    argument :description, String, required: false

    field :board, Types::BoardType, null: true
    field :errors, [ String ], null: false

    def resolve(id:, **attributes)
      board = Board.find_by(id: id)

      return { board: nil, errors: [ "Board not found" ] } unless board

      if board.update(attributes)
        { board: board, errors: [] }
      else
        { board: nil, errors: board.errors.full_messages }
      end
    end
  end
end
