import { useState, useMemo } from 'react'
import { useLazyQuery } from '@apollo/client/react'
import { GET_TASKS } from '../graphql/queries/Tasks'

export default function useFilteredTasks() {
  const [filters, setFilters] = useState(null)
  const [fetchTasks, { data, loading }] = useLazyQuery(GET_TASKS, { fetchPolicy: 'network-only' })

  const filteredTasks = useMemo(() => {
    if (!data?.tasks) return null
    return data.tasks.map(t => ({
      ...t,
      listId: t.list.id,
    }))
  }, [data])

  function applyFilters({ completed, dueBefore, dueAfter, listIds }) {
    const variables = {}
    if (completed) variables.completed = true
    if (dueBefore) variables.dueBefore = dueBefore
    if (dueAfter) variables.dueAfter = dueAfter
    if (listIds && listIds.length > 0) variables.listIds = listIds

    setFilters({ completed, dueBefore, dueAfter, listIds })
    fetchTasks({ variables })
  }

  function clearFilters() {
    setFilters(null)
  }

  const isActive = filters !== null

  return { filteredTasks, isActive, applyFilters, clearFilters }
}
