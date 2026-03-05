module Mutations
  class CreateTask < BaseMutation
    argument :title, String, required: true
    argument :list_id, ID, required: true
    argument :description, String, required: false
    argument :due_at, GraphQL::Types::ISO8601DateTime, required: false
    argument :position, Integer, required: true

    field :task, Types::TaskType, null: true
    field :errors, [ String ], null: false

    def resolve(title:, list_id:, position:, **attributes)
      task = Task.new(title: title, list_id: list_id, position: position, **attributes)

      if task.save
        { task: task, errors: [] }
      else
        { task: nil, errors: task.errors.full_messages }
      end
    end
  end
end
