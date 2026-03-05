module Mutations
  class EditList < BaseMutation
    argument :id, ID, required: true
    argument :name, String, required: false
    argument :position, Integer, required: false

    field :list, Types::ListType, null: true
    field :errors, [ String ], null: false

    def resolve(id:, **attributes)
      list = List.find_by(id: id)

      return { list: nil, errors: [ "List not found" ] } unless list

      if list.update(attributes.compact)
        { list: list, errors: [] }
      else
        { list: nil, errors: list.errors.full_messages }
      end
    end
  end
end
