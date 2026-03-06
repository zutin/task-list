import { useState, useRef, useEffect } from 'react'

export default function FilterPanel({ lists, onApply, onClear, isActive }) {
  const [open, setOpen] = useState(false)
  const panelRef = useRef(null)

  const [completed, setCompleted] = useState(false)
  const [dueBefore, setDueBefore] = useState('')
  const [dueAfter, setDueAfter] = useState('')
  const [selectedListIds, setSelectedListIds] = useState([])

  useEffect(() => {
    if (!open) return
    function handleClickOutside(e) {
      if (panelRef.current && !panelRef.current.contains(e.target)) {
        setOpen(false)
      }
    }
    document.addEventListener('mousedown', handleClickOutside)
    return () => document.removeEventListener('mousedown', handleClickOutside)
  }, [open])

  function handleApply() {
    onApply({
      completed,
      dueBefore: dueBefore ? new Date(dueBefore + 'T23:59:59').toISOString() : null,
      dueAfter: dueAfter ? new Date(dueAfter + 'T00:00:00').toISOString() : null,
      listIds: selectedListIds.length > 0 ? selectedListIds : null,
    })
    setOpen(false)
  }

  function handleClear() {
    setCompleted(false)
    setDueBefore('')
    setDueAfter('')
    setSelectedListIds([])
    onClear()
    setOpen(false)
  }

  function toggleList(listId) {
    setSelectedListIds(prev =>
      prev.includes(listId) ? prev.filter(id => id !== listId) : [...prev, listId]
    )
  }

  return (
    <div className="filter-wrapper" ref={panelRef}>
      <button
        className={`filter-btn ${isActive ? 'filter-btn-active' : ''}`}
        onClick={() => setOpen(o => !o)}
      >
        ⚙ Filters{isActive ? ' ●' : ''}
      </button>

      {open && (
        <div className="filter-panel">
          <div className="filter-section">
            <label className="filter-checkbox-label">
              <input
                type="checkbox"
                checked={completed}
                onChange={e => setCompleted(e.target.checked)}
              />
              Only completed tasks
            </label>
          </div>

          <div className="filter-section">
            <label className="filter-label">Due after</label>
            <input
              type="date"
              className="filter-date-input"
              value={dueAfter}
              onChange={e => setDueAfter(e.target.value)}
            />
          </div>

          <div className="filter-section">
            <label className="filter-label">Due before</label>
            <input
              type="date"
              className="filter-date-input"
              value={dueBefore}
              onChange={e => setDueBefore(e.target.value)}
            />
          </div>

          <div className="filter-section">
            <label className="filter-label">Lists</label>
            <div className="filter-list-checks">
              {lists.map(list => (
                <label key={list.id} className="filter-checkbox-label">
                  <input
                    type="checkbox"
                    checked={selectedListIds.includes(list.id)}
                    onChange={() => toggleList(list.id)}
                  />
                  {list.name}
                </label>
              ))}
            </div>
          </div>

          <div className="filter-actions">
            <button className="filter-apply-btn" onClick={handleApply}>Apply</button>
            {isActive && (
              <button className="filter-clear-btn" onClick={handleClear}>Clear filters</button>
            )}
          </div>
        </div>
      )}
    </div>
  )
}
