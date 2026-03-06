const API_URL = 'http://localhost:3000/graphql'

Cypress.Commands.add('visitPage', () => {
  cy.visit('http://localhost:5173')
})

Cypress.Commands.add('gql', (query, variables = {}) => {
  return cy.request({
    method: 'POST',
    url: API_URL,
    body: { query, variables },
    headers: { 'Content-Type': 'application/json' },
  }).then(res => res.body.data)
})

Cypress.Commands.add('createBoard', (name, description) => {
  return cy.gql(
    `mutation ($input: CreateBoardInput!) { createBoard(input: $input) { board { id name } errors } }`,
    { input: { name, description } }
  ).then(data => data.createBoard.board)
})

Cypress.Commands.add('createList', (name, boardId) => {
  return cy.gql(
    `mutation ($input: CreateListInput!) { createList(input: $input) { list { id name } errors } }`,
    { input: { name, boardId, position: 1 } }
  ).then(data => data.createList.list)
})

Cypress.Commands.add('createTask', (title, listId, description) => {
  return cy.gql(
    `mutation ($input: CreateTaskInput!) { createTask(input: $input) { task { id title } errors } }`,
    { input: { title, listId, description, position: 1 } }
  ).then(data => data.createTask.task)
})

Cypress.Commands.add('deleteBoard', (id) => {
  return cy.gql(
    `mutation ($input: DeleteBoardInput!) { deleteBoard(input: $input) { id errors } }`,
    { input: { id } }
  )
})

Cypress.Commands.add('cleanupAll', () => {
  return cy.gql(`{ boards { id } }`).then(data => {
    const boards = data.boards || []
    const chain = cy.wrap(null)
    boards.forEach(board => {
      chain.then(() => cy.deleteBoard(board.id))
    })
    return chain
  })
})