class Task < ApplicationRecord
  include Positionable

  belongs_to :list

  scope :by_completed, ->(completed) { completed ? where.not(completed_at: nil) : where(completed_at: nil) }
  scope :due_before, ->(date) { where(due_at: ...date) }
  scope :due_after, ->(date) { where(due_at: date..) }

  validates :title, :position, presence: true
  validates :title, length: { maximum: 255 }
  validates :description, length: { maximum: 3000 }

  private

  def positionable_siblings = Task.where(list_id: list_id).where.not(id: id)

  def old_positionable_siblings = Task.where(list_id: list_id_was).where.not(id: id)

  def positionable_scope_changed? = list_id_changed? && list_id_was.present?
end
