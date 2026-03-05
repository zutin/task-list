# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :create_list, mutation: Mutations::CreateList
    field :edit_list, mutation: Mutations::EditList
    field :delete_list, mutation: Mutations::DeleteList
  end
end
