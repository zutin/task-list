class Task < ApplicationRecord
  validates :title, presence: true
  validates :title, length: { maximum: 255 }
  validates :description, length: { maximum: 3000 }
end
