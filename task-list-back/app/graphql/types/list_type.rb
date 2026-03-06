class Types::ListType < Types::BaseObject
  field :id, ID, null: false
  field :name, String, null: false
  field :position, Integer, null: false
  field :tasks, [ Types::TaskType ], null: true
  field :created_at, GraphQL::Types::ISO8601DateTime, null: false
  field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
end
