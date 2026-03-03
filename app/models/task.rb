class Task < ApplicationRecord
  belongs_to :list

  validates :title, :position, presence: true
  validates :title, length: { maximum: 255 }
  validates :description, length: { maximum: 3000 }

  # The task position in the list is unique and must not be repeated
  # There cannot be multiple tasks with same position in the same list
  # I think it is easier to have a after_save callback that keeps this in line instead of a DB level check
  # And also make all new tasks to have the last position possible to avoid errors
end
