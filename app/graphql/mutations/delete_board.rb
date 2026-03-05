module Mutations
  class DeleteBoard < BaseMutation
    argument :id, ID, required: true

    field :id, ID, null: true
    field :errors, [ String ], null: false

    def resolve(id:)
      board = Board.find_by(id: id)

      return { id: nil, errors: [ "Board not found" ] } unless board

      board.destroy

      { id: board.id.to_s, errors: [] }
    end
  end
end
