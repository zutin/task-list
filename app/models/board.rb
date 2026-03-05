class Board < ApplicationRecord
  has_many :lists, dependent: :destroy
  has_many :tasks, through: :lists

  validates :name, presence: true
  validates :name, length: { maximum: 100 }
end
