import { gql } from "@apollo/client";

const CREATE_LIST = gql`
  mutation CreateList($input: CreateListInput!) {
    createList(input: $input) {
      list {
        id
        name
        position
      }
      errors
    }
  }
`;

const UPDATE_LIST = gql`
  mutation EditList($id: ID!, $name: String, $position: Int, $boardId: ID) {
    editList(input: { id: $id, name: $name, position: $position, boardId: $boardId }) {
      list {
        id
        name
        position
      }
      errors
    }
  }
`;

const DELETE_LIST = gql`
  mutation DeleteList($input: DeleteListInput!) {
    deleteList(input: $input) {
      id
      errors
    }
  }
`;

export { CREATE_LIST, UPDATE_LIST, DELETE_LIST };
