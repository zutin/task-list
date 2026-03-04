module Mutations
  class CreateList < BaseMutation
    argument :name, String, required: true
    argument :position, Integer, required: true

    field :list, Types::ListType, null: true
    field :errors, [ String ], null: false

    def resolve(name:, position:)
      list = List.new(name: name, position: position)

      if list.save
        { list: list, errors: [] }
      else
        { list: nil, errors: list.errors.full_messages }
      end
    end
  end
end
