# GraphQL API Documentation

## Types

### BoardType
| Field | Type | Nullable |
|-------|------|----------|
| id | ID | No |
| name | String | No |
| description | String | Yes |
| lists | [ListType] | Yes |
| createdAt | ISO8601DateTime | No |
| updatedAt | ISO8601DateTime | No |

### ListType
| Field | Type | Nullable |
|-------|------|----------|
| id | ID | No |
| name | String | No |
| position | Integer | No |
| tasks | [TaskType] | Yes |
| createdAt | ISO8601DateTime | No |
| updatedAt | ISO8601DateTime | No |

### TaskType
| Field | Type | Nullable |
|-------|------|----------|
| id | ID | No |
| title | String | No |
| description | String | Yes |
| dueAt | ISO8601DateTime | Yes |
| completedAt | ISO8601DateTime | Yes |
| position | Integer | No |
| list | ListType | No |
| createdAt | ISO8601DateTime | No |
| updatedAt | ISO8601DateTime | No |

---

## Queries

### Get Board
Fetches a board by ID, including its lists and tasks.
```graphql
query {
  board(id: "1") {
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
```

Variables:
| Name | Type | Required |
|------|------|----------|
| id | ID | Yes |

Return: [BoardType](#boardtype)
```json
{
  "data": {
    "board": {
      "id": "1",
      "name": "My Board",
      "description": "A sample board",
      "lists": [
        {
          "id": "1",
          "name": "To Do",
          "position": 1,
          "tasks": [
            {
              "id": "1",
              "title": "My Task",
              "description": "A sample task",
              "position": 1,
              "dueAt": null,
              "completedAt": null,
              "createdAt": "2026-03-06T00:00:00Z"
            }
          ]
        }
      ]
    }
  }
}
```

### Get All Boards
Fetches all boards ordered by creation date (desc) then name (asc).
```graphql
query {
  boards {
    id
    name
    description
  }
}
```

Return: [[BoardType]](#boardtype)
```json
{
  "data": {
    "boards": [
      {
        "id": "1",
        "name": "My Board",
        "description": "A sample board"
      }
    ]
  }
}
```

### Get Task
Fetches a single task by ID.
```graphql
query {
  task(id: "1") {
    id
    title
    description
    dueAt
    completedAt
    position
    createdAt
  }
}
```

Variables:
| Name | Type | Required |
|------|------|----------|
| id | ID | Yes |

Return: [TaskType](#tasktype)

### Get Tasks (with filters)
Fetches tasks with optional filters for list, completion status, and due date range.
```graphql
query {
  tasks(listIds: ["1", "2"], completed: true, dueBefore: "2026-04-01T00:00:00Z", dueAfter: "2026-03-01T00:00:00Z") {
    id
    title
    description
    position
    dueAt
    completedAt
    createdAt
    list {
      id
    }
  }
}
```

Variables:
| Name | Type | Required | Description |
|------|------|----------|-------------|
| listIds | [ID] | No | Filter tasks by list IDs |
| completed | Boolean | No | Filter by completion status |
| dueBefore | ISO8601DateTime | No | Filter tasks due before this date |
| dueAfter | ISO8601DateTime | No | Filter tasks due after this date |

Return: [[TaskType]](#tasktype)

### Get List
Fetches a single list by ID.
```graphql
query {
  list(id: "1") {
    id
    name
    position
    tasks {
      id
      title
    }
  }
}
```

Variables:
| Name | Type | Required |
|------|------|----------|
| id | ID | Yes |

Return: [ListType](#listtype)

### Get All Lists
Fetches all lists with their tasks, ordered by position.
```graphql
query {
  lists {
    id
    name
    position
    tasks {
      id
      title
    }
  }
}
```

Return: [[ListType]](#listtype)

---

## Mutations

### Create Board
```graphql
mutation {
  createBoard(input: { name: "My Board", description: "A sample board" }) {
    board {
      id
      name
      description
    }
    errors
  }
}
```

Variables:
| Name | Type | Required |
|------|------|----------|
| name | String | Yes |
| description | String | No |

Return: [BoardType](#boardtype)
```json
{
  "data": {
    "createBoard": {
      "board": {
        "id": "1",
        "name": "My Board",
        "description": "A sample board"
      },
      "errors": []
    }
  }
}
```

### Edit Board
```graphql
mutation {
  editBoard(input: { id: "1", name: "Updated Board", description: "Updated description" }) {
    board {
      id
      name
      description
    }
    errors
  }
}
```

Variables:
| Name | Type | Required |
|------|------|----------|
| id | ID | Yes |
| name | String | No |
| description | String | No |

Return: [BoardType](#boardtype)

### Delete Board
```graphql
mutation {
  deleteBoard(input: { id: "1" }) {
    id
    errors
  }
}
```

Variables:
| Name | Type | Required |
|------|------|----------|
| id | ID | Yes |

Return:
```json
{
  "data": {
    "deleteBoard": {
      "id": "1",
      "errors": []
    }
  }
}
```

### Create List
```graphql
mutation {
  createList(input: { name: "To Do", boardId: "1", position: 1 }) {
    list {
      id
      name
      position
    }
    errors
  }
}
```

Variables:
| Name | Type | Required |
|------|------|----------|
| name | String | Yes |
| boardId | ID | Yes |
| position | Integer | Yes |

Return: [ListType](#listtype)
```json
{
  "data": {
    "createList": {
      "list": {
        "id": "1",
        "name": "To Do",
        "position": 1
      },
      "errors": []
    }
  }
}
```

### Edit List
```graphql
mutation {
  editList(input: { id: "1", name: "Done", position: 2 }) {
    list {
      id
      name
      position
    }
    errors
  }
}
```

Variables:
| Name | Type | Required |
|------|------|----------|
| id | ID | Yes |
| name | String | No |
| boardId | ID | No |
| position | Integer | No |

Return: [ListType](#listtype)

### Delete List
```graphql
mutation {
  deleteList(input: { id: "1" }) {
    id
    errors
  }
}
```

Variables:
| Name | Type | Required |
|------|------|----------|
| id | ID | Yes |

Return:
```json
{
  "data": {
    "deleteList": {
      "id": "1",
      "errors": []
    }
  }
}
```

### Create Task
```graphql
mutation {
  createTask(input: { title: "My Task", listId: "1", position: 1, description: "A sample task", dueAt: "2026-04-01T00:00:00Z" }) {
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
```

Variables:
| Name | Type | Required |
|------|------|----------|
| title | String | Yes |
| listId | ID | Yes |
| position | Integer | Yes |
| description | String | No |
| dueAt | ISO8601DateTime | No |

Return: [TaskType](#tasktype)
```json
{
  "data": {
    "createTask": {
      "task": {
        "id": "1",
        "title": "My Task",
        "description": "A sample task",
        "dueAt": "2026-04-01T00:00:00Z",
        "completedAt": null,
        "position": 1
      },
      "errors": []
    }
  }
}
```

### Edit Task
```graphql
mutation {
  editTask(input: { id: "1", title: "Updated Task", description: "Updated description", dueAt: "2026-05-01T00:00:00Z", completedAt: "2026-03-06T12:00:00Z", position: 2, listId: "2" }) {
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
```

Variables:
| Name | Type | Required |
|------|------|----------|
| id | ID | Yes |
| title | String | No |
| description | String | No |
| dueAt | ISO8601DateTime | No |
| completedAt | ISO8601DateTime | No |
| position | Integer | No |
| listId | ID | No |

Return: [TaskType](#tasktype)

### Delete Task
```graphql
mutation {
  deleteTask(input: { id: "1" }) {
    id
    errors
  }
}
```

Variables:
| Name | Type | Required |
|------|------|----------|
| id | ID | Yes |

Return:
```json
{
  "data": {
    "deleteTask": {
      "id": "1",
      "errors": []
    }
  }
}
```
