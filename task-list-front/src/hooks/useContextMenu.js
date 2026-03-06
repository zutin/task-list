import { useState, useRef, useEffect } from 'react'

export default function useContextMenu() {
  const [menuOpen, setMenuOpen] = useState(false)
  const [menuPos, setMenuPos] = useState({ x: 0, y: 0 })
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

  function openMenu(e) {
    e.preventDefault()
    setMenuPos({ x: e.clientX, y: e.clientY })
    setMenuOpen(true)
    setConfirmDelete(false)
  }

  function closeMenu() {
    setMenuOpen(false)
    setConfirmDelete(false)
  }

  return { menuOpen, menuPos, menuRef, confirmDelete, setConfirmDelete, openMenu, closeMenu }
}
