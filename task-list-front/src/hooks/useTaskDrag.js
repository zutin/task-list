import { useState, useEffect, useMemo } from 'react'
import { useMutation } from '@apollo/client/react'
import { arrayMove } from '@dnd-kit/sortable'
import { UPDATE_TASK } from '../graphql/queries/Tasks'

export default function useTaskDrag({ fetchedTasks, refetch }) {
  const [tasks, setTasks] = useState(fetchedTasks)
  const [editTask] = useMutation(UPDATE_TASK)

  const fetchedKey = useMemo(
    () => fetchedTasks.map(t => `${t.id}:${t.listId}:${t.position}:${t.completedAt}`).join(','),
    [fetchedTasks]
  )

  useEffect(() => {
    setTasks(fetchedTasks)
  }, [fetchedKey])

  function handleDragEnd({ active, over }) {
    if (!over || active.id === over.id) return

    const taskId = String(active.id)
    const overId = String(over.id)

    const activeTask = tasks.find(t => t.id === taskId)
    const overTask = tasks.find(t => t.id === overId)

    if (!activeTask || !overTask) return
    // Only reorder within the same list
    if (activeTask.listId !== overTask.listId) return

    const listId = activeTask.listId
    const listTasks = tasks
      .filter(t => t.listId === listId)
      .sort((a, b) => a.position - b.position)

    const fromIndex = listTasks.findIndex(t => t.id === taskId)
    const toIndex = listTasks.findIndex(t => t.id === overId)

    if (fromIndex === -1 || toIndex === -1 || fromIndex === toIndex) return

    const reordered = arrayMove(listTasks, fromIndex, toIndex)
    const newPosition = toIndex + 1

    // Optimistic update
    setTasks(prev => {
      const otherTasks = prev.filter(t => t.listId !== listId)
      const updated = reordered.map((t, i) => ({ ...t, position: i + 1 }))
      return [...otherTasks, ...updated]
    })

    editTask({ variables: { id: taskId, position: newPosition, listId } })
      .then(() => refetch())
      .catch((err) => {
        console.error('Failed to update task:', err)
        refetch()
      })
  }

  function moveTaskToList(taskId, newListId) {
    editTask({ variables: { id: taskId, position: 1, listId: newListId } })
      .then(() => refetch())
      .catch((err) => {
        console.error('Failed to move task:', err)
        refetch()
      })
  }

  function toggleComplete(taskId, isCurrentlyCompleted) {
    const completedAt = isCurrentlyCompleted ? null : new Date().toISOString()
    editTask({ variables: { id: taskId, completedAt } })
      .then(() => refetch())
      .catch((err) => {
        console.error('Failed to toggle task:', err)
        refetch()
      })
  }

  return { tasks, handleDragEnd, moveTaskToList, toggleComplete }
}
