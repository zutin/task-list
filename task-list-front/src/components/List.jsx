import { useState, useRef, useEffect } from 'react'
import { useSortable, SortableContext, verticalListSortingStrategy } from '@dnd-kit/sortable'
import { CSS } from '@dnd-kit/utilities'
import Task from "./Task"
import ListModal from "./ListModal"
import TaskModal from "./TaskModal"

export default function List({ id, name, tasks, lists, onMoveToList, onToggleComplete, onUpdateTask, onUpdateList, onDeleteList, onDeleteTask, onCreateTask }) {
  const [menuOpen, setMenuOpen] = useState(false)
  const [menuPos, setMenuPos] = useState({ x: 0, y: 0 })
  const [showModal, setShowModal] = useState(false)
  const [showNewTaskModal, setShowNewTaskModal] = useState(false)
  const [confirmDelete, setConfirmDelete] = useState(false)
  const menuRef = useRef(null)

  const sortableId = `list-${id}`
  const { attributes, listeners, setNodeRef, transform, transition, isDragging } = useSortable({ id: sortableId })

  const style = {
    transform: CSS.Transform.toString(transform),
    transition,
    opacity: isDragging ? 0.5 : 1,
  }

  const taskIds = tasks.map(t => t.id)

  function handleContextMenu(e) {
    e.preventDefault()
    setMenuPos({ x: e.clientX, y: e.clientY })
    setMenuOpen(true)
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

  function handleModalSave(fields) {
    onUpdateList(id, fields)
  }

  return (
    <>
      <div ref={setNodeRef} style={style} className={`column ${isDragging ? 'column-dragging' : ''}`}>
        <h2
          className="column-title"
          {...listeners}
          {...attributes}
          onContextMenu={handleContextMenu}
        >
          {name}
        </h2>
        <div className="column-items">
          <SortableContext items={taskIds} strategy={verticalListSortingStrategy}>
            {tasks.map(task => (
              <Task key={task.id} task={task} lists={lists} onMoveToList={onMoveToList} onToggleComplete={onToggleComplete} onUpdateTask={onUpdateTask} onDeleteTask={onDeleteTask} />
            ))}
          </SortableContext>
        </div>
      </div>

      {showModal && (
        <ListModal
          mode="edit"
          list={{ id, name }}
          onSave={handleModalSave}
          onClose={() => setShowModal(false)}
        />
      )}

      {showNewTaskModal && (
        <TaskModal
          mode="create"
          lists={lists}
          defaultListId={id}
          onSave={(fields) => onCreateTask(fields)}
          onClose={() => setShowNewTaskModal(false)}
        />
      )}

      {menuOpen && (
        <div
          ref={menuRef}
          className="context-menu"
          style={{ top: menuPos.y, left: menuPos.x }}
        >
          <div className="context-menu-label">{name.length > 20 ? name.slice(0, 20) + '…' : name}</div>
          <button
            className="context-menu-item"
            onClick={() => { setMenuOpen(false); setShowNewTaskModal(true) }}
          >
            Add task
          </button>
          <button
            className="context-menu-item"
            onClick={() => { setMenuOpen(false); setShowModal(true) }}
          >
            Edit list
          </button>
          <div className="context-menu-divider" />
          {confirmDelete ? (
            <div className="context-menu-confirm">
              <span className="context-menu-confirm-label">Delete this list?</span>
              <div className="context-menu-confirm-actions">
                <button className="context-menu-confirm-btn confirm-yes" onClick={() => { setMenuOpen(false); setConfirmDelete(false); onDeleteList(id) }}>Yes</button>
                <button className="context-menu-confirm-btn confirm-no" onClick={() => setConfirmDelete(false)}>No</button>
              </div>
            </div>
          ) : (
            <button className="context-menu-item context-menu-item-danger" onClick={() => setConfirmDelete(true)}>Delete list</button>
          )}
        </div>
      )}
    </>
  )
}
