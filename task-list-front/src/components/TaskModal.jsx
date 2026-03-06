import { useState, useRef, useEffect } from 'react'

function toLocalDateString(date) {
  const d = new Date(date)
  const y = d.getFullYear()
  const m = String(d.getMonth() + 1).padStart(2, '0')
  const day = String(d.getDate()).padStart(2, '0')
  return `${y}-${m}-${day}`
}

function toISOFromLocal(dateStr) {
  if (!dateStr) return null
  const [y, m, d] = dateStr.split('-').map(Number)
  return new Date(y, m - 1, d, 23, 59, 59).toISOString()
}

export default function TaskModal({ mode = 'edit', task, lists, defaultListId, onSave, onClose }) {
  const isEdit = mode === 'edit'

  const [title, setTitle] = useState(isEdit ? task.title : '')
  const [editingTitle, setEditingTitle] = useState(!isEdit)
  const [description, setDescription] = useState(isEdit ? (task.description || '') : '')
  const [editingDesc, setEditingDesc] = useState(!isEdit)
  const [dueDate, setDueDate] = useState(isEdit && task.dueAt ? toLocalDateString(task.dueAt) : '')
  const [editingDue, setEditingDue] = useState(!isEdit)
  const [listId, setListId] = useState(isEdit ? task.listId : (defaultListId || lists[0]?.id || ''))

  const titleRef = useRef(null)
  const descRef = useRef(null)
  const dueRef = useRef(null)

  useEffect(() => { if (editingTitle && titleRef.current) titleRef.current.focus() }, [editingTitle])
  useEffect(() => { if (editingDesc && descRef.current) descRef.current.focus() }, [editingDesc])
  useEffect(() => { if (editingDue && dueRef.current) dueRef.current.focus() }, [editingDue])

  function handleSave() {
    if (!title.trim()) return
    const fields = {}

    if (isEdit) {
      if (title !== task.title) fields.title = title
      if (description !== (task.description || '')) fields.description = description
      const originalDue = task.dueAt ? toLocalDateString(task.dueAt) : ''
      if (dueDate !== originalDue) fields.dueAt = toISOFromLocal(dueDate)
      if (listId !== task.listId) {
        fields.listId = listId
        fields.position = 1
      }
      if (Object.keys(fields).length > 0) {
        onSave(fields)
      }
    } else {
      fields.title = title
      fields.description = description || undefined
      fields.dueAt = toISOFromLocal(dueDate) || undefined
      fields.listId = listId
      onSave(fields)
    }
    onClose()
  }

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="task-modal" onClick={e => e.stopPropagation()}>
        <button className="task-modal-close" onClick={onClose}>✕</button>

        <div className="task-modal-body">
          <div className="task-modal-field">
            {editingTitle ? (
              <input
                ref={titleRef}
                className="task-modal-input task-modal-input-title"
                value={title}
                onChange={e => setTitle(e.target.value)}
                onBlur={() => isEdit && setEditingTitle(false)}
                onKeyDown={e => e.key === 'Enter' && isEdit && setEditingTitle(false)}
                placeholder="Task title"
              />
            ) : (
              <h2 className="task-modal-display task-modal-display-title" onClick={() => setEditingTitle(true)}>
                {title || <span className="task-modal-placeholder">Click to add title</span>}
              </h2>
            )}
          </div>

          <div className="task-modal-field">
            <label className="task-modal-label">Description</label>
            {editingDesc ? (
              <textarea
                ref={descRef}
                className="task-modal-input task-modal-textarea"
                value={description}
                onChange={e => setDescription(e.target.value)}
                onBlur={() => isEdit && setEditingDesc(false)}
                placeholder="Add a description..."
                rows={3}
              />
            ) : (
              <p className="task-modal-display task-modal-display-desc" onClick={() => setEditingDesc(true)}>
                {description || <span className="task-modal-placeholder">Click to add description</span>}
              </p>
            )}
          </div>

          <div className="task-modal-field">
            <label className="task-modal-label">Due date</label>
            {editingDue ? (
              <input
                ref={dueRef}
                type="date"
                className="task-modal-input"
                value={dueDate}
                onChange={e => setDueDate(e.target.value)}
                onBlur={() => isEdit && setEditingDue(false)}
              />
            ) : (
              <p className="task-modal-display" onClick={() => setEditingDue(true)}>
                {dueDate ? new Date(dueDate + 'T00:00:00').toLocaleDateString() : <span className="task-modal-placeholder">Click to set due date</span>}
              </p>
            )}
          </div>

          {isEdit && task.createdAt && (
            <div className="task-modal-field">
              <label className="task-modal-label">Created</label>
              <p className="task-modal-display task-modal-readonly">
                {new Date(task.createdAt).toLocaleString()}
              </p>
            </div>
          )}

          <div className="task-modal-field">
            <label className="task-modal-label">List</label>
            <select
              className="task-modal-input task-modal-select"
              value={listId}
              onChange={e => setListId(e.target.value)}
            >
              {lists.map(l => (
                <option key={l.id} value={l.id}>{l.name}</option>
              ))}
            </select>
          </div>
        </div>

        <div className="modal-actions">
          <button className="modal-btn modal-btn-secondary" onClick={onClose}>Cancel</button>
          <button className="modal-btn modal-btn-primary" onClick={handleSave} disabled={!title.trim()}>
            {isEdit ? 'Save changes' : 'Create task'}
          </button>
        </div>
      </div>
    </div>
  )
}
