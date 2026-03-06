import { gql } from "@apollo/client";

const GET_TASKS = gql`
  query GetTasks($listIds: [ID!], $completed: Boolean, $dueBefore: ISO8601DateTime, $dueAfter: ISO8601DateTime) {
    tasks(listIds: $listIds, completed: $completed, dueBefore: $dueBefore, dueAfter: $dueAfter) {
      id
      title
      description
      dueAt
      completedAt
      position
      createdAt
      updatedAt
    }
  }
`;

const GET_TASK = gql`
  query GetTask($id: ID!) {
    task(id: $id) {
      id
      title
      description
      dueAt
      completedAt
      position
      createdAt
      updatedAt
    }
  }
`;

const CREATE_TASK = gql`
  mutation CreateTask($input: CreateTaskInput!) {
    createTask(input: $input) {
      task {
        id
        title
        description
        dueAt
        completedAt
        position
      }
      errors
    }
  }
`;

const UPDATE_TASK = gql`
  mutation EditTask($id: ID!, $title: String, $description: String, $position: Int, $listId: ID, $completedAt: ISO8601DateTime, $dueAt: ISO8601DateTime) {
    editTask(input: { id: $id, title: $title, description: $description, position: $position, listId: $listId, completedAt: $completedAt, dueAt: $dueAt }) {
      task {
        id
        title
        description
        dueAt
        completedAt
        position
      }
      errors
    }
  }
`;

export { GET_TASKS, GET_TASK, CREATE_TASK, UPDATE_TASK };
