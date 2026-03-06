import type { Task as TaskType } from "../graphql/types/Task"
import { useDroppable } from '@dnd-kit/core'
import Task from "./Task"

interface ListProps {
  id: string
  name: string
  position: number
}

export default function List({ id, name, tasks }: ListProps & { tasks: TaskType[] }) {
  const { setNodeRef, isOver } = useDroppable({ id })

  return (
    <div ref={setNodeRef} className={`column ${isOver ? 'over' : ''}`}>
      
      <h2 className="column-title">{id} - {name}</h2>
      <div className="column-items">
        {tasks.map(task => (
          <Task key={task.id} {...task} />
        ))}
      </div>
    </div>
  )
}
