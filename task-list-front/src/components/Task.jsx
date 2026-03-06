import { useState } from 'react'
import { useSortable } from '@dnd-kit/sortable'
import { CSS } from '@dnd-kit/utilities'
import useContextMenu from '../hooks/useContextMenu'
import TaskModal from './TaskModal'

export default function Task({ task, lists, onMoveToList, onToggleComplete, onUpdateTask, onDeleteTask }) {
  const [showModal, setShowModal] = useState(false)
  const { menuOpen, menuPos, menuRef, confirmDelete, setConfirmDelete, openMenu, closeMenu } = useContextMenu()

  const { attributes, listeners, setNodeRef, transform, transition, isDragging } = useSortable({ id: task.id })

  const style = {
    transform: CSS.Transform.toString(transform),
    transition,
    opacity: isDragging ? 0.4 : 1,
  }

  function handleContextMenu(e) {
    openMenu(e)
  }

  function handleClick() {
    if (!isDragging) setShowModal(true)
  }

  function handleMove(listId) {
    closeMenu()
    onMoveToList(task.id, listId)
  }

  function getDueBadgeClass() {
    if (!task.dueAt) return ''
    const due = new Date(task.dueAt)
    const now = new Date()
    if (task.completedAt && new Date(task.completedAt) <= due) return 'due-badge due-green'
    if (due < now) return 'due-badge due-red'
    return 'due-badge due-yellow'
  }

  function handleModalSave(fields) {
    onUpdateTask(task.id, fields)
  }

  const otherLists = lists.filter(l => l.id !== task.listId)

  return (
    <>
      <div
        ref={setNodeRef}
        style={style}
        {...listeners}
        {...attributes}
        onContextMenu={handleContextMenu}
        onClick={handleClick}
        className={`task-card ${isDragging ? 'dragging' : ''} ${task.completedAt ? 'completed' : ''}`}
      >
        <div className="task-header">
          <span className="task-title">{task.title.length > 20 ? task.title.slice(0, 20) + '…' : task.title}</span>
          {task.completedAt && <span className="task-badge completed-badge">✔ Done</span>}
        </div>
        {task.description && <p className="task-description">{task.description.length > 60 ? task.description.slice(0, 60) + '…' : task.description}</p>}
        <div className="task-meta">
          {task.dueAt && (
            <span className={`task-badge ${getDueBadgeClass()}`}>
              Due: {new Date(task.dueAt).toLocaleDateString()}
            </span>
          )}
          <span className="task-pos" style={{ marginLeft: 'auto' }}>#{task.id}</span>
        </div>
      </div>

      {showModal && (
        <TaskModal
          mode="edit"
          task={task}
          lists={lists}
          onSave={handleModalSave}
          onClose={() => setShowModal(false)}
        />
      )}

      {menuOpen && (
        <div
          ref={menuRef}
          className="context-menu"
          style={{ top: menuPos.y, left: menuPos.x }}
        >
          <div className="context-menu-label">{task.title.length > 20 ? task.title.slice(0, 20) + '…' : task.title}</div>
          <button
            className="context-menu-item"
            onClick={() => { closeMenu(); onToggleComplete(task.id, !!task.completedAt) }}
          >
            {task.completedAt ? 'Mark as incomplete' : 'Mark as complete'}
          </button>
          <button
            className="context-menu-item"
            onClick={() => { closeMenu(); setShowModal(true) }}
          >
            Edit task
          </button>
          <div className="context-menu-divider" />
          <div className="context-menu-label">Move to</div>
          {otherLists.map(list => (
            <button
              key={list.id}
              className="context-menu-item"
              onClick={() => handleMove(list.id)}
            >
              {list.name}
            </button>
          ))}
          {otherLists.length === 0 && (
            <div className="context-menu-item disabled">No other lists</div>
          )}
          <div className="context-menu-divider" />
          {confirmDelete ? (
            <div className="context-menu-confirm">
              <span className="context-menu-confirm-label">Delete this task?</span>
              <div className="context-menu-confirm-actions">
                <button className="context-menu-confirm-btn confirm-yes" onClick={() => { closeMenu(); onDeleteTask(task.id) }}>Yes</button>
                <button className="context-menu-confirm-btn confirm-no" onClick={() => setConfirmDelete(false)}>No</button>
              </div>
            </div>
          ) : (
            <button className="context-menu-item context-menu-item-danger" onClick={() => setConfirmDelete(true)}>Delete task</button>
          )}
        </div>
      )}
    </>
  )
}
