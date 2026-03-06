import { useState, useRef, useEffect } from 'react'
import { useSortable } from '@dnd-kit/sortable'
import { CSS } from '@dnd-kit/utilities'

export default function Task({ task, lists, onMoveToList, onToggleComplete }) {
  const [menuOpen, setMenuOpen] = useState(false)
  const [menuPos, setMenuPos] = useState({ x: 0, y: 0 })
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

  // Close menu on outside click
  useEffect(() => {
    if (!menuOpen) return
    function handleClick(e) {
      if (menuRef.current && !menuRef.current.contains(e.target)) {
        setMenuOpen(false)
      }
    }
    document.addEventListener('mousedown', handleClick)
    return () => document.removeEventListener('mousedown', handleClick)
  }, [menuOpen])

  function handleMove(listId) {
    setMenuOpen(false)
    onMoveToList(task.id, listId)
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
        className={`task-card ${isDragging ? 'dragging' : ''} ${task.completedAt ? 'completed' : ''}`}
      >
        <div className="task-header">
          <span className="task-title">{task.title}</span>
          {task.completedAt && <span className="task-badge completed-badge">✔ Done</span>}
        </div>
        {task.description && <p className="task-description">{task.description}</p>}
        <div className="task-meta">
          {task.dueAt && <span className="task-due">Due: {new Date(task.dueAt).toLocaleDateString()}</span>}
          <span className="task-pos">#{task.id}</span>
        </div>
      </div>

      {menuOpen && (
        <div
          ref={menuRef}
          className="context-menu"
          style={{ top: menuPos.y, left: menuPos.x }}
        >
          <p className="context-menu-label">{task.title}</p>
          <button
            className="context-menu-item"
            onClick={() => { setMenuOpen(false); onToggleComplete(task.id, !!task.completedAt) }}
          >
            {task.completedAt ? 'Mark as incomplete' : 'Mark as complete'}
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
