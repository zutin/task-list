describe('task list page spec', () => {
  const boardName = 'Render Test Board'
  const boardDesc = 'A board for render tests'
  const listName = 'Render Test List'
  const taskTitle = 'Render Test Task'
  const taskDesc = 'A task for render tests'

  before(() => {
    cy.cleanupAll()
    cy.createBoard(boardName, boardDesc).then(board => {
      cy.createList(listName, board.id).then(list => {
        cy.createTask(taskTitle, list.id, taskDesc)
      })
    })
  })

  beforeEach(() => {
    cy.visitPage()
    cy.get('.sidebar-item').contains(boardName).click()
  })

  after(() => {
    cy.cleanupAll()
  })

  it('renders the sidebar with boards', () => {
    cy.get('.sidebar').should('be.visible')
    cy.get('.sidebar-title').should('have.text', 'Boards')
    cy.get('.sidebar-item').contains(boardName).should('be.visible')
  })

  it('renders the board title and description', () => {
    cy.get('.board-title').should('have.text', boardName)
    cy.get('.board-description').should('contain.text', boardDesc)
  })

  it('renders the filter button and add list button', () => {
    cy.get('.filter-btn').should('be.visible').and('contain.text', 'Filters')
    cy.get('.add-list-btn').should('be.visible').and('have.text', '+ Add list')
  })

  it('renders lists as columns', () => {
    cy.get('.column').should('have.length.at.least', 1)
    cy.get('.column-title').contains(listName).should('be.visible')
  })

  it('renders tasks inside lists', () => {
    cy.get('.task-card').should('have.length.at.least', 1)
    cy.get('.task-card').contains(taskTitle).should('be.visible')
  })

  it('renders the filter panel when clicking the filter button', () => {
    cy.get('.filter-btn').click()
    cy.get('.filter-panel').should('be.visible')
  })

  it('renders the new list modal when clicking add list', () => {
    cy.get('.add-list-btn').click()
    cy.get('.task-modal').should('be.visible')

    cy.get('.task-modal-label').contains('List name').should('be.visible')
  })

  it('renders the task modal when clicking the task card', () => {
    cy.get('.task-card').contains(taskTitle).click()
    cy.get('.task-modal').should('be.visible')

    cy.get('.task-modal-display-title').should('have.text', taskTitle)

    cy.get('.task-modal-label').contains('Description').should('be.visible')
    cy.get('.task-modal-display-desc').should('have.text', taskDesc)

    cy.get('.task-modal-label').contains('Due date').should('be.visible')

    cy.get('.task-modal-label').contains('Created').should('be.visible')
    cy.get('.task-modal-readonly').should('be.visible').and('not.be.empty')

    cy.get('.task-modal-label').contains('List').should('be.visible')
    cy.get('.task-modal-select').should('contain.text', listName)
  })
})