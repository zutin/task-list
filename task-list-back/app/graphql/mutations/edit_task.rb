module Mutations
  class EditTask < BaseMutation
    argument :id, ID, required: true
    argument :title, String, required: false
    argument :description, String, required: false
    argument :due_at, GraphQL::Types::ISO8601DateTime, required: false
    argument :completed_at, GraphQL::Types::ISO8601DateTime, required: false
    argument :position, Integer, required: false
    argument :list_id, ID, required: false

    field :task, Types::TaskType, null: true
    field :errors, [ String ], null: false

    def resolve(id:, **attributes)
      task = Task.find_by(id: id)

      return { task: nil, errors: [ "Task not found" ] } unless task

      if task.update(attributes)
        { task: task, errors: [] }
      else
        { task: nil, errors: task.errors.full_messages }
      end
    end
  end
end
