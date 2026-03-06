import { useState, useRef, useEffect } from 'react'

export default function ListModal({ mode = 'edit', list, onSave, onClose }) {
  const isEdit = mode === 'edit'
  const [name, setName] = useState(isEdit ? list.name : '')
  const [editingName, setEditingName] = useState(!isEdit)
  const nameRef = useRef(null)

  useEffect(() => {
    if (editingName && nameRef.current) nameRef.current.focus()
  }, [editingName])

  function handleSave() {
    if (!name.trim()) return
    if (isEdit) {
      if (name !== list.name) onSave({ name })
    } else {
      onSave({ name })
    }
    onClose()
  }

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="task-modal" onClick={e => e.stopPropagation()}>
        <button className="task-modal-close" onClick={onClose}>✕</button>

        <div className="task-modal-body">
          <div className="task-modal-field">
            <label className="task-modal-label">List name</label>
            {editingName ? (
              <input
                ref={nameRef}
                className="task-modal-input task-modal-input-title"
                value={name}
                onChange={e => setName(e.target.value)}
                onBlur={() => isEdit && setEditingName(false)}
                onKeyDown={e => {
                  if (e.key === 'Enter') handleSave()
                  if (e.key === 'Escape') onClose()
                }}
                placeholder="List name"
              />
            ) : (
              <h2 className="task-modal-display task-modal-display-title" onClick={() => setEditingName(true)}>
                {name || <span className="task-modal-placeholder">Click to add name</span>}
              </h2>
            )}
          </div>
        </div>

        <div className="modal-actions">
          <button className="modal-btn modal-btn-secondary" onClick={onClose}>Cancel</button>
          <button className="modal-btn modal-btn-primary" onClick={handleSave} disabled={!name.trim()}>
            {isEdit ? 'Save changes' : 'Create list'}
          </button>
        </div>
      </div>
    </div>
  )
}
