import { useState, useRef, useEffect } from 'react'
import { useSortable } from '@dnd-kit/sortable'
import { CSS } from '@dnd-kit/utilities'
import TaskModal from './TaskModal'

export default function Task({ task, lists, onMoveToList, onToggleComplete, onUpdateTask }) {
  const [menuOpen, setMenuOpen] = useState(false)
  const [menuPos, setMenuPos] = useState({ x: 0, y: 0 })
  const [showModal, setShowModal] = useState(false)
  const menuRef = useRef(null)

  const { attributes, listeners, setNodeRef, transform, transition, isDragging } = useSortable({ id: task.id })

  const style = {
    transform: CSS.Transform.toString(transform),
    transition,
    opacity: isDragging ? 0.4 : 1,
  }

  function handleContextMenu(e) {
    e.preventDefault()
    setMenuPos({ x: e.clientX, y: e.clientY })
    setMenuOpen(true)
  }

  function handleClick() {
    if (!isDragging) setShowModal(true)
  }

  useEffect(() => {
    if (!menuOpen) return
    function handleClickOutside(e) {
      if (menuRef.current && !menuRef.current.contains(e.target)) {
        setMenuOpen(false)
      }
    }
    document.addEventListener('mousedown', handleClickOutside)
    return () => document.removeEventListener('mousedown', handleClickOutside)
  }, [menuOpen])

  function handleMove(listId) {
    setMenuOpen(false)
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
          <span className="task-pos">#{task.id}</span>
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
            onClick={() => { setMenuOpen(false); onToggleComplete(task.id, !!task.completedAt) }}
          >
            {task.completedAt ? 'Mark as incomplete' : 'Mark as complete'}
          </button>
          <button
            className="context-menu-item"
            onClick={() => { setMenuOpen(false); setShowModal(true) }}
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
        </div>
      )}
    </>
  )
}
