describe('task list crud operations', () => {
  const boardName = 'Cypress Test Board'
  const boardDesc = 'Board created by Cypress'
  const listName = 'Cypress Test List'
  const taskTitle = 'Cypress Test Task'
  const taskDesc = 'Task created by Cypress'

  beforeEach(() => {
    cy.visitPage()
  })

  before(() => {
    cy.cleanupAll()
  })

  after(() => {
    cy.cleanupAll()
  })

  it('creates a board from the sidebar', () => {
    cy.get('.sidebar-add-btn').click()
    cy.get('.task-modal').should('be.visible')
    cy.get('.task-modal-label').contains('Board name').should('be.visible')

    cy.get('.task-modal-input-title').clear().type(boardName)
    cy.get('.task-modal-textarea').clear().type(boardDesc)
    cy.get('.modal-btn-primary').contains('Create board').click()

    cy.get('.task-modal').should('not.exist')
    cy.get('.sidebar-item').contains(boardName).should('be.visible')
  })

  it('selects the new board and creates a list', () => {
    cy.get('.sidebar-item').contains(boardName).click()

    cy.get('.board-title').should('have.text', boardName)

    cy.get('.add-list-btn').click()
    cy.get('.task-modal').should('be.visible')
    cy.get('.task-modal-label').contains('List name').should('be.visible')

    cy.get('.task-modal-input-title').clear().type(listName)
    cy.get('.modal-btn-primary').contains('Create list').click()

    cy.get('.task-modal').should('not.exist')
    cy.get('.column-title').contains(listName).should('be.visible')
  })

  it('creates a task via right-click on list', () => {
    cy.get('.sidebar-item').contains(boardName).click()
    cy.get('.column-title').contains(listName).should('be.visible')

    cy.get('.column-title').contains(listName).rightclick()
    cy.get('.context-menu').should('be.visible')
    cy.get('.context-menu-item').contains('Add task').click()

    cy.get('.task-modal').should('be.visible')
    cy.get('.task-modal-input-title').clear().type(taskTitle)
    cy.get('.task-modal-textarea').clear().type(taskDesc)
    cy.get('.modal-btn-primary').contains('Create task').click()

    cy.get('.task-modal').should('not.exist')
    cy.get('.task-card').contains(taskTitle).should('be.visible')
  })

  it('marks a task as complete via right-click', () => {
    cy.get('.sidebar-item').contains(boardName).click()
    cy.get('.task-card').contains(taskTitle).should('be.visible')

    cy.get('.task-card').contains(taskTitle).rightclick()
    cy.get('.context-menu').should('be.visible')
    cy.get('.context-menu-item').contains('Mark as complete').click()

    cy.get('.task-card').contains(taskTitle)
      .closest('.task-card')
      .should('have.class', 'completed')
      .find('.completed-badge')
      .should('contain.text', 'Done')
  })

  it('filters for completed tasks only', () => {
    cy.get('.sidebar-item').contains(boardName).click()
    cy.get('.task-card').contains(taskTitle).should('be.visible')

    cy.get('.filter-btn').click()
    cy.get('.filter-panel').should('be.visible')

    cy.get('.filter-checkbox-label').contains('Only completed tasks').find('input').check()
    cy.get('.filter-apply-btn').click()

    cy.get('.task-card').each($card => {
      cy.wrap($card).should('have.class', 'completed')
    })

    cy.get('.filter-btn').click()
    cy.get('.filter-clear-btn').click()
  })

  it('deletes the task via right-click', () => {
    cy.get('.sidebar-item').contains(boardName).click()
    cy.get('.task-card').contains(taskTitle).should('be.visible')

    cy.get('.task-card').contains(taskTitle).rightclick()
    cy.get('.context-menu').should('be.visible')
    cy.get('.context-menu-item-danger').contains('Delete task').click()
    cy.get('.confirm-yes').click()

    cy.get('.task-card').should('not.exist')
  })

  it('deletes the list via right-click', () => {
    cy.get('.sidebar-item').contains(boardName).click()
    cy.get('.column-title').contains(listName).should('be.visible')

    cy.get('.column-title').contains(listName).rightclick()
    cy.get('.context-menu').should('be.visible')
    cy.get('.context-menu-item-danger').contains('Delete list').click()
    cy.get('.confirm-yes').click()

    cy.get('.columns').should('not.contain.text', listName)
  })

  it('deletes the board via right-click on sidebar', () => {
    cy.get('.sidebar-item').contains(boardName).should('be.visible')

    cy.get('.sidebar-item').contains(boardName).rightclick()
    cy.get('.context-menu').should('be.visible')
    cy.get('.context-menu-item-danger').contains('Delete board').click()
    cy.get('.confirm-yes').click()

    cy.get('.sidebar-list').should('not.contain.text', boardName)
  })
})
