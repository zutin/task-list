module Mutations
  class DeleteTask < BaseMutation
    argument :id, ID, required: true

    field :id, ID, null: true
    field :errors, [ String ], null: false

    def resolve(id:)
      task = Task.find_by(id: id)

      return { id: nil, errors: [ "Task not found" ] } unless task

      task.destroy

      { id: task.id.to_s, errors: [] }
    end
  end
end
