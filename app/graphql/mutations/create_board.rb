module Mutations
  class CreateBoard < BaseMutation
    argument :name, String, required: true
    argument :description, String, required: false

    field :board, Types::BoardType, null: true
    field :errors, [ String ], null: false

    def resolve(name:, description: nil)
      board = Board.new(name: name, description: description)

      if board.save
        { board: board, errors: [] }
      else
        { board: nil, errors: board.errors.full_messages }
      end
    end
  end
end
