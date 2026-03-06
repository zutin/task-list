import { useMemo } from 'react'
import { useQuery } from '@apollo/client/react'
import { GET_BOARD } from './graphql/queries/Boards'
import type { Task } from './graphql/types/Task'
import type { List } from './graphql/types/List'
import type { Board } from './graphql/types/Board'

interface BoardQueryTask {
  id: string
  title: string
  description?: string
  position: number
  dueAt?: string
  completedAt?: string
  createdAt: string
}

interface BoardQueryList {
  id: string
  name: string
  position: number
  tasks: BoardQueryTask[]
}

interface GetBoardResponse {
  board: {
    id: string
    name: string
    description?: string
    lists: BoardQueryList[]
  }
}

interface UseFetchBoardResult {
  loading: boolean
  error: Error | undefined
  board: Board | null
  lists: List[]
  tasks: Task[]
  refetch: () => void
}

function useFetchBoard(): UseFetchBoardResult {
  const { loading, error, data, refetch } = useQuery<GetBoardResponse>(GET_BOARD, {
    variables: { id: '1' }
  })

  const result = useMemo(() => {
    if (!data) {
      return { board: null, lists: [] as List[], tasks: [] as Task[] }
    }

    const { id, name, description, lists: rawLists } = data.board

    const board: Board = { id, name, description, createdAt: '' }

    const lists: List[] = rawLists.map(l => ({
      id: l.id,
      name: l.name,
      position: l.position,
      createdAt: '',
      boardId: id,
    }))

    const tasks: Task[] = rawLists.flatMap(l =>
      l.tasks.map(t => ({
        ...t,
        listId: l.id,
      }))
    )

    return { board, lists, tasks }
  }, [data])

  return { loading, error, refetch, ...result }
}

export default useFetchBoard