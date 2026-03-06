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
          description
          position
          dueAt
          completedAt
          createdAt
        }
      }
    }
  }
`;

const CREATE_BOARD = gql`
  mutation CreateBoard($input: CreateBoardInput!) {
    createBoard(input: $input) {
      board {
        id
        name
        description
      }
      errors
    }
  }
`;

const UPDATE_BOARD = gql`
  mutation EditBoard($input: EditBoardInput!) {
    editBoard(input: $input) {
      board {
        id
        name
        description
      }
      errors
    }
  }
`;

export { GET_BOARDS, GET_BOARD, CREATE_BOARD, UPDATE_BOARD };