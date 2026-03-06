import { useState, useEffect, useMemo } from 'react'
import { useMutation } from '@apollo/client/react'
import { arrayMove } from '@dnd-kit/sortable'
import { CREATE_LIST, UPDATE_LIST, DELETE_LIST } from '../graphql/queries/Lists'

export default function useListDrag({ fetchedLists, boardId, refetch }) {
  const [lists, setLists] = useState(fetchedLists)
  const [editList] = useMutation(UPDATE_LIST)
  const [addList] = useMutation(CREATE_LIST)
  const [removeList] = useMutation(DELETE_LIST)

  const fetchedKey = useMemo(
    () => fetchedLists.map(l => `${l.id}:${l.position}:${l.name}`).join(','),
    [fetchedLists]
  )

  useEffect(() => {
    setLists(fetchedLists)
  }, [fetchedKey])

  function handleListDragEnd({ active, over }) {
    if (!over || active.id === over.id) return

    const activeId = String(active.id).replace('list-', '')
    const overId = String(over.id).replace('list-', '')

    // Ignore if over target is not a list
    if (!String(over.id).startsWith('list-')) return

    const sorted = [...lists].sort((a, b) => a.position - b.position)
    const fromIndex = sorted.findIndex(l => l.id === activeId)
    const toIndex = sorted.findIndex(l => l.id === overId)

    if (fromIndex === -1 || toIndex === -1 || fromIndex === toIndex) return

    const reordered = arrayMove(sorted, fromIndex, toIndex)
    const newPosition = toIndex + 1

    // Optimistic update
    setLists(reordered.map((l, i) => ({ ...l, position: i + 1 })))

    editList({ variables: { id: activeId, position: newPosition } })
      .then(() => refetch())
      .catch((err) => {
        console.error('Failed to update list:', err)
        refetch()
      })
  }

  function updateList(listId, fields) {
    editList({ variables: { id: listId, ...fields } })
      .then(() => refetch())
      .catch((err) => {
        console.error('Failed to update list:', err)
        refetch()
      })
  }

  function createList(fields) {
    addList({ variables: { input: { name: fields.name, boardId, position: 1 } } })
      .then(() => refetch())
      .catch((err) => {
        console.error('Failed to create list:', err)
        refetch()
      })
  }

  function deleteList(listId) {
    setLists(prev => prev.filter(l => l.id !== listId))
    removeList({ variables: { input: { id: listId } } })
      .then(() => refetch())
      .catch((err) => {
        console.error('Failed to delete list:', err)
        refetch()
      })
  }

  return { lists, handleListDragEnd, updateList, createList, deleteList }
}
