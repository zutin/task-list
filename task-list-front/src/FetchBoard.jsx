import { useMemo } from 'react'
import { useQuery } from '@apollo/client/react'
import { GET_BOARD } from './graphql/queries/Boards'

function useFetchBoard(boardId) {
  const { loading, error, data, refetch } = useQuery(GET_BOARD, {
    variables: { id: boardId },
    skip: !boardId,
  })

  const result = useMemo(() => {
    if (!data) {
      return { board: null, lists: [], tasks: [] }
    }

    const { id, name, description, lists: rawLists } = data.board

    const board = { id, name, description, createdAt: '' }

    const lists = rawLists.map(l => ({
      id: l.id,
      name: l.name,
      position: l.position,
      createdAt: '',
      boardId: id,
    }))

    const tasks = rawLists.flatMap(l =>
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
