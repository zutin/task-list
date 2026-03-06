import { useState } from 'react'
import { DndContext, PointerSensor, useSensor, useSensors, closestCenter } from '@dnd-kit/core'
import { SortableContext, horizontalListSortingStrategy } from '@dnd-kit/sortable'
import './App.css'
import useFetchBoard from './FetchBoard'
import useTaskDrag from './hooks/useTaskDrag'
import useListDrag from './hooks/useListDrag'
import List from './components/List'
import ListModal from './components/ListModal'

function filteredCollisionDetection(args) {
  const { active, droppableContainers, ...rest } = args
  const isListDrag = String(active.id).startsWith('list-')

  const filtered = droppableContainers.filter(container => {
    const id = String(container.id)
    return isListDrag ? id.startsWith('list-') : !id.startsWith('list-')
  })

  return closestCenter({ ...args, droppableContainers: filtered })
}

function App() {
  const { loading, error, board, lists: fetchedLists, tasks: fetchedTasks, refetch } = useFetchBoard()
  const { tasks, handleDragEnd: handleTaskDragEnd, moveTaskToList, toggleComplete, updateTask, deleteTask, createTask } = useTaskDrag({ fetchedTasks, refetch })
  const { lists, handleListDragEnd, updateList, createList, deleteList } = useListDrag({ fetchedLists, boardId: board?.id, refetch })
  const [showNewListModal, setShowNewListModal] = useState(false)
  const sensors = useSensors(useSensor(PointerSensor, { activationConstraint: { distance: 8 } }))

  function handleDragEnd(event) {
    if (String(event.active.id).startsWith('list-')) {
      handleListDragEnd(event)
    } else {
      handleTaskDragEnd(event)
    }
  }

  if (loading) return <p className='text-xl'>Loading...</p>
  if (error) return <p className='text-xl'>Error :(</p>
  if (!board) return <p className='text-xl'>No board found.</p>

  const sortedLists = [...lists].sort((a, b) => a.position - b.position)

  return (
    <DndContext
      sensors={sensors}
      collisionDetection={filteredCollisionDetection}
      onDragEnd={handleDragEnd}
    >
      <div className="board">
        <div className="board-header">
          <h1 className="board-title">{board.name}</h1>
          <button className="add-list-btn" onClick={() => setShowNewListModal(true)}>+ Add list</button>
        </div>
        <div className="columns">
          <SortableContext items={sortedLists.map(l => `list-${l.id}`)} strategy={horizontalListSortingStrategy}>
            {sortedLists.map(list => (
              <List
                key={list.id}
                id={list.id}
                name={list.name}
                position={list.position}
                lists={sortedLists}
                onMoveToList={moveTaskToList}
                onToggleComplete={toggleComplete}
                onUpdateTask={updateTask}
                onUpdateList={updateList}
                onDeleteList={deleteList}
                onDeleteTask={deleteTask}
                onCreateTask={createTask}
                tasks={tasks
                  .filter(task => task.listId === list.id)
                  .sort((a, b) => a.position - b.position)}
              />
            ))}
          </SortableContext>
        </div>
      </div>

      {showNewListModal && (
        <ListModal
          mode="create"
          onSave={createList}
          onClose={() => setShowNewListModal(false)}
        />
      )}
    </DndContext>
  )
}

export default App
