module Mutations
  class CreateList < BaseMutation
    argument :name, String, required: true
    argument :board_id, ID, required: true
    argument :position, Integer, required: true

    field :list, Types::ListType, null: true
    field :errors, [ String ], null: false

    def resolve(name:, board_id:, position:)
      list = List.new(name: name, board_id: board_id, position: position)

      if list.save
        { list: list, errors: [] }
      else
        { list: nil, errors: list.errors.full_messages }
      end
    end
  end
end
