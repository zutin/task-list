class List < ApplicationRecord
  include Positionable

  belongs_to :board
  has_many :tasks, dependent: :destroy

  validates :name, :position, presence: true
  validates :name, length: { maximum: 100 }

  private

  def positionable_siblings = List.where(board_id: board_id).where.not(id: id)

  def old_positionable_siblings = List.where(board_id: board_id_was).where.not(id: id)

  def positionable_scope_changed? = board_id_changed? && board_id_was.present?
end
