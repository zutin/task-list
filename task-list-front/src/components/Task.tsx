import type { Task as TaskType } from '../graphql/types/Task'
import { useDraggable } from '@dnd-kit/core'

export default function Task(task: TaskType) {
  const { attributes, listeners, setNodeRef, transform, isDragging } = useDraggable({ id: task.id })

  const style = transform
      ? { transform: `translate3d(${transform.x}px, ${transform.y}px, 0)` }
      : undefined

  return (
    <div ref={setNodeRef}
      style={style}
      {...listeners}
      {...attributes}
      className={`item ${isDragging ? 'dragging' : ''}`}>

      {task.title} - {task.id} (list: {task.listId}, pos: {task.position})

      {task.dueAt && <span> — Due: {task.dueAt}</span>}
      {task.completedAt && <span> ✔ Completed</span>}
    </div>
  )
}
