import { useState, useRef, useEffect } from 'react'

export default function BoardModal({ mode = 'edit', board, onSave, onClose }) {
  const isEdit = mode === 'edit'

  const [name, setName] = useState(isEdit ? board.name : '')
  const [editingName, setEditingName] = useState(!isEdit)
  const [description, setDescription] = useState(isEdit ? (board.description || '') : '')
  const [editingDesc, setEditingDesc] = useState(!isEdit)

  const nameRef = useRef(null)
  const descRef = useRef(null)

  useEffect(() => { if (editingName && nameRef.current) nameRef.current.focus() }, [editingName])
  useEffect(() => { if (editingDesc && descRef.current) descRef.current.focus() }, [editingDesc])

  function handleSave() {
    if (!name.trim()) return
    if (isEdit) {
      const fields = {}
      if (name !== board.name) fields.name = name
      if (description !== (board.description || '')) fields.description = description
      if (Object.keys(fields).length > 0) onSave(fields)
    } else {
      onSave({ name, description: description || undefined })
    }
    onClose()
  }

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="task-modal" onClick={e => e.stopPropagation()}>
        <button className="task-modal-close" onClick={onClose}>✕</button>

        <div className="task-modal-body">
          <div className="task-modal-field">
            <label className="task-modal-label">Board name</label>
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
                placeholder="Board name"
              />
            ) : (
              <h2 className="task-modal-display task-modal-display-title" onClick={() => setEditingName(true)}>
                {name || <span className="task-modal-placeholder">Click to add name</span>}
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
        </div>

        <div className="modal-actions">
          <button className="modal-btn modal-btn-secondary" onClick={onClose}>Cancel</button>
          <button className="modal-btn modal-btn-primary" onClick={handleSave} disabled={!name.trim()}>
            {isEdit ? 'Save changes' : 'Create board'}
          </button>
        </div>
      </div>
    </div>
  )
}
