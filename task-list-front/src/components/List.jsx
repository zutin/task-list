import { SortableContext, verticalListSortingStrategy } from '@dnd-kit/sortable'
import Task from "./Task"

export default function List({ id, name, tasks, lists, onMoveToList, onToggleComplete }) {
  const taskIds = tasks.map(t => t.id)

  return (
    <div className="column">
      <h2 className="column-title">{name}</h2>
      <div className="column-items">
        <SortableContext items={taskIds} strategy={verticalListSortingStrategy}>
          {tasks.map(task => (
            <Task key={task.id} task={task} lists={lists} onMoveToList={onMoveToList} onToggleComplete={onToggleComplete} />
          ))}
        </SortableContext>
      </div>
    </div>
  )
}
