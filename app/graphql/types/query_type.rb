# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    field :task, Types::TaskType, null: true, description: "Fetches a task by ID." do
      argument :id, ID, required: true, description: "ID of the task."
    end

    field :tasks, [ Types::TaskType ], null: true, description: "Fetches all tasks." do
      argument :list_ids, [ ID ], required: false, description: "IDs of the lists to filter tasks by."
    end

    def task(id:) = Task.find_by(id: id)

    def tasks(list_ids: nil)
      scope = list_ids ? Task.where(list_id: list_ids) : Task.all
      scope.order(:list_id, :position)
    end
  end
end
