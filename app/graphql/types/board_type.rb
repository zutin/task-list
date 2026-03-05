class Types::BoardType < Types::BaseObject
  field :id, ID, null: false
  field :name, String, null: false
  field :description, String, null: true
  field :lists, [ Types::ListType ], null: true
  field :created_at, GraphQL::Types::ISO8601DateTime, null: false
  field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
end
