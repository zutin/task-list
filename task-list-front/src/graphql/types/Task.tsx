export type Task = {
  id: string;
  title: string;
  description?: string;
  position: number;
  dueAt?: string;
  completedAt?: string;
  createdAt: string;
  listId: string;
};
