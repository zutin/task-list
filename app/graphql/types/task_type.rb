class Types::TaskType < Types::BaseObject
  field :id, ID, null: false
  field :title, String, null: false
  field :description, String, null: true
  field :due_at, GraphQL::Types::ISO8601DateTime, null: true
  field :completed, Boolean, null: false
  field :position, Integer, null: false
  field :created_at, GraphQL::Types::ISO8601DateTime, null: false
  field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
end
