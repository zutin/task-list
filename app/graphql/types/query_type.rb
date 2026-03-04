# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    field :task, Types::TaskType, null: true, description: "Fetches a task by ID." do
      argument :id, ID, required: true, description: "ID of the task."
    end

    field :tasks, [ Types::TaskType ], null: true, description: "Fetches all tasks." do
      argument :list_ids, [ ID ], required: false, description: "IDs of the lists to filter tasks by."
      argument :completed, Boolean, required: false, description: "Filter by completion status."
      argument :due_before, GraphQL::Types::ISO8601DateTime, required: false, description: "Filter tasks due before this date."
      argument :due_after, GraphQL::Types::ISO8601DateTime, required: false, description: "Filter tasks due after this date."
    end

    def task(id:) = Task.find_by(id: id)

    def tasks(list_ids: nil, completed: nil, due_before: nil, due_after: nil)
      scope = list_ids ? Task.where(list_id: list_ids) : Task.all
      scope = scope.by_completed(completed) unless completed.nil?
      scope = scope.due_before(due_before) if due_before
      scope = scope.due_after(due_after) if due_after
      scope.order(:list_id, :position)
    end
  end
end
