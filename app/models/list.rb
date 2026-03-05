class List < ApplicationRecord
  belongs_to :board
  has_many :tasks, dependent: :destroy

  validates :name, :position, presence: true
  validates :name, length: { maximum: 100 }

  # This position is a bit different than the task one
  # Here, position sets the list order from left to right
  # So position 1 is far left (first list on the left side of the screen), while position 10 (or more) is far right
  # It must also be unique and updated after each board movement (this may be a after_save as well)
  # I will also have to make sure all new lists are created with the last position possible to avoid errors
end
