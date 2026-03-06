import { useState, useEffect } from 'react'
import { useMutation } from '@apollo/client/react'
import type { DragEndEvent } from '@dnd-kit/core'
import { UPDATE_TASK } from '../graphql/queries/Tasks'
import type { Task } from '../graphql/types/Task'

interface UseTaskDragOptions {
  fetchedTasks: Task[]
  refetch: () => void
}

export default function useTaskDrag({ fetchedTasks, refetch }: UseTaskDragOptions) {
  const [tasks, setTasks] = useState<Task[]>(fetchedTasks)
  const [editTask] = useMutation(UPDATE_TASK)

  useEffect(() => {
    setTasks(fetchedTasks)
  }, [fetchedTasks])

  function handleDragEnd({ active, over }: DragEndEvent) {
    if (!over) return

    const taskId = String(active.id)
    const newListId = String(over.id)

    const task = tasks.find(t => t.id === taskId)
    if (!task || task.listId === newListId) return

    // Optimistic UI update
    setTasks(prev =>
      prev.map(item =>
        item.id === taskId ? { ...item, listId: newListId } : item
      )
    )

    // Persist via GraphQL, then refetch to sync positions
    editTask({
      variables: { id: taskId, listId: newListId }
    })
      .then(() => refetch())
      .catch((err) => {
        console.error('Failed to update task:', err)
        refetch()
      })
  }

  return { tasks, handleDragEnd }
}
