import { gql } from "@apollo/client";

const GET_BOARDS = gql`
  query GetBoards {
    boards {
      id
      name
      description
    }
  }
`;

const GET_BOARD = gql`
  query GetBoard($id: ID!) {
    board(id: $id) {
      id
      name
      description
      lists {
        id
        name
        position
        tasks {
          id
          title
          position
          dueAt
          completedAt
        }
      }
    }
  }
`;

export { GET_BOARDS, GET_BOARD };