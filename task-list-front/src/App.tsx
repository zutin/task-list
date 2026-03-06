import { DndContext } from '@dnd-kit/core'
import './App.css'
import useFetchBoard from './FetchBoard'
import useTaskDrag from './hooks/useTaskDrag'
import List from './components/List'

function App() {
  const { loading, error, board, lists, tasks: fetchedTasks, refetch } = useFetchBoard()
  const { tasks, handleDragEnd } = useTaskDrag({ fetchedTasks, refetch })

  if (loading) return <p className='text-xl'>Loading...</p>
  if (error) return <p className='text-xl'>Error :(</p>
  if (!board) return <p className='text-xl'>No board found.</p>

  return (
    <DndContext onDragEnd={handleDragEnd}>
      <div className="board">
        <h1 className="board-title">{board.name}</h1>
        <div className="columns">
          {lists.map(list => (
            <List
              key={list.id}
              id={list.id}
              name={list.name}
              position={list.position}
              tasks={tasks.filter(task => task.listId === list.id)}
            />
          ))}
        </div>
      </div>
    </DndContext>
  )
}

export default App
