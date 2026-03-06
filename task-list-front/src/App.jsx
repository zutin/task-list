import { DndContext, PointerSensor, useSensor, useSensors } from '@dnd-kit/core'
import './App.css'
import useFetchBoard from './FetchBoard'
import useTaskDrag from './hooks/useTaskDrag'
import List from './components/List'

function App() {
  const { loading, error, board, lists, tasks: fetchedTasks, refetch } = useFetchBoard()
  const { tasks, handleDragEnd, moveTaskToList, toggleComplete } = useTaskDrag({ fetchedTasks, refetch })
  const sensors = useSensors(useSensor(PointerSensor, { activationConstraint: { distance: 8 } }))

  if (loading) return <p className='text-xl'>Loading...</p>
  if (error) return <p className='text-xl'>Error :(</p>
  if (!board) return <p className='text-xl'>No board found.</p>

  return (
    <DndContext
      sensors={sensors}
      onDragEnd={handleDragEnd}
    >
      <div className="board">
        <h1 className="board-title">{board.name}</h1>
        <div className="columns">
          {lists.map(list => (
            <List
              key={list.id}
              id={list.id}
              name={list.name}
              position={list.position}
              lists={lists}
              onMoveToList={moveTaskToList}
              onToggleComplete={toggleComplete}
              tasks={tasks
                .filter(task => task.listId === list.id)
                .sort((a, b) => a.position - b.position)}
            />
          ))}
        </div>
      </div>
    </DndContext>
  )
}

export default App
