module Mutations
  class DeleteList < BaseMutation
    argument :id, ID, required: true

    field :id, ID, null: true
    field :errors, [ String ], null: false

    def resolve(id:)
      list = List.find_by(id: id)

      return { id: nil, errors: [ "List not found" ] } unless list

      list.destroy

      { id: list.id.to_s, errors: [] }
    end
  end
end
