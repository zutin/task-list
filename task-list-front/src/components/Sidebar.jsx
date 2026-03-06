import { useState, useRef, useEffect } from 'react'
import { useQuery, useMutation } from '@apollo/client/react'
import { GET_BOARDS, CREATE_BOARD, UPDATE_BOARD, DELETE_BOARD } from '../graphql/queries/Boards'
import BoardModal from './BoardModal'

export default function Sidebar({ selectedBoardId, onSelectBoard, collapsed, onToggleCollapse }) {
  const { data, loading, refetch } = useQuery(GET_BOARDS)
  const [createBoard] = useMutation(CREATE_BOARD)
  const [updateBoard] = useMutation(UPDATE_BOARD)
  const [deleteBoard] = useMutation(DELETE_BOARD)

  const boards = data?.boards || []

  const [showModal, setShowModal] = useState(false)
  const [modalMode, setModalMode] = useState('create')
  const [editingBoard, setEditingBoard] = useState(null)

  const [menuOpen, setMenuOpen] = useState(false)
  const [menuPos, setMenuPos] = useState({ x: 0, y: 0 })
  const [menuBoard, setMenuBoard] = useState(null)
  const [confirmDelete, setConfirmDelete] = useState(false)
  const menuRef = useRef(null)

  useEffect(() => {
    if (!menuOpen) return
    function handleClickOutside(e) {
      if (menuRef.current && !menuRef.current.contains(e.target)) {
        setMenuOpen(false)
        setConfirmDelete(false)
      }
    }
    document.addEventListener('mousedown', handleClickOutside)
    return () => document.removeEventListener('mousedown', handleClickOutside)
  }, [menuOpen])

  function handleContextMenu(e, board) {
    e.preventDefault()
    setMenuPos({ x: e.clientX, y: e.clientY })
    setMenuBoard(board)
    setMenuOpen(true)
    setConfirmDelete(false)
  }

  function handleCreate(fields) {
    createBoard({ variables: { input: fields } })
      .then(() => refetch())
      .catch(err => console.error('Failed to create board:', err))
  }

  function handleUpdate(fields) {
    if (!editingBoard) return
    updateBoard({ variables: { input: { id: editingBoard.id, ...fields } } })
      .then(() => refetch())
      .catch(err => console.error('Failed to update board:', err))
  }

  function handleDelete(boardId) {
    deleteBoard({ variables: { input: { id: boardId } } })
      .then(() => {
        refetch()
        if (boardId === selectedBoardId) onSelectBoard(null)
      })
      .catch(err => console.error('Failed to delete board:', err))
  }

  if (collapsed) {
    return null
  }

  return (
    <>
      <aside className="sidebar">
        <div className="sidebar-header">
          <h2 className="sidebar-title">Boards</h2>
          <div className="sidebar-header-actions">
            <button className="sidebar-add-btn" onClick={() => { setModalMode('create'); setEditingBoard(null); setShowModal(true) }} title="Add board">+</button>
            <button className="sidebar-toggle-btn" onClick={onToggleCollapse} title="Collapse sidebar">✕</button>
          </div>
        </div>
        <div className="sidebar-list">
          {loading && <p className="sidebar-loading">Loading...</p>}
          {boards.map(board => (
            <button
              key={board.id}
              className={`sidebar-item ${board.id === selectedBoardId ? 'sidebar-item-active' : ''}`}
              onClick={() => onSelectBoard(board.id)}
              onContextMenu={(e) => handleContextMenu(e, board)}
            >
              <span className="sidebar-item-name">{board.name}</span>
            </button>
          ))}
          {!loading && boards.length === 0 && (
            <p className="sidebar-empty">No boards yet</p>
          )}
        </div>
      </aside>

      {showModal && (
        <BoardModal
          mode={modalMode}
          board={editingBoard}
          onSave={modalMode === 'create' ? handleCreate : handleUpdate}
          onClose={() => setShowModal(false)}
        />
      )}

      {menuOpen && menuBoard && (
        <div
          ref={menuRef}
          className="context-menu"
          style={{ top: menuPos.y, left: menuPos.x }}
        >
          <div className="context-menu-label">{menuBoard.name.length > 20 ? menuBoard.name.slice(0, 20) + '…' : menuBoard.name}</div>
          <button
            className="context-menu-item"
            onClick={() => { setMenuOpen(false); setEditingBoard(menuBoard); setModalMode('edit'); setShowModal(true) }}
          >
            Edit board
          </button>
          <div className="context-menu-divider" />
          {confirmDelete ? (
            <div className="context-menu-confirm">
              <span className="context-menu-confirm-label">Delete this board?</span>
              <div className="context-menu-confirm-actions">
                <button className="context-menu-confirm-btn confirm-yes" onClick={() => { setMenuOpen(false); setConfirmDelete(false); handleDelete(menuBoard.id) }}>Yes</button>
                <button className="context-menu-confirm-btn confirm-no" onClick={() => setConfirmDelete(false)}>No</button>
              </div>
            </div>
          ) : (
            <button className="context-menu-item context-menu-item-danger" onClick={() => setConfirmDelete(true)}>Delete board</button>
          )}
        </div>
      )}
    </>
  )
}
