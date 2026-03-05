module Positionable
  extend ActiveSupport::Concern

  included do
    before_save :adjust_sibling_positions
    after_destroy :close_position_gap
  end

  private

  def adjust_sibling_positions
    return unless position_changed? || new_record? || positionable_scope_changed?

    if new_record?
      positionable_siblings.where("position >= ?", position).update_all("position = position + 1")
    elsif positionable_scope_changed?
      old_positionable_siblings.where("position > ?", position_was).update_all("position = position - 1")
      positionable_siblings.where("position >= ?", position).update_all("position = position + 1")
    else
      old_pos = position_was
      new_pos = position

      if new_pos < old_pos
        positionable_siblings.where(position: new_pos...old_pos).update_all("position = position + 1")
      elsif new_pos > old_pos
        positionable_siblings.where(position: (old_pos + 1)..new_pos).update_all("position = position - 1")
      end
    end
  end

  def close_position_gap
    positionable_siblings.where("position > ?", position).update_all("position = position - 1")
  end

  # Override the following three methods in the including model to define the scope of siblings
  # and handle scope changes (e.g. task moving to another list)

  def positionable_siblings
    raise NotImplementedError
  end

  def old_positionable_siblings
    raise NotImplementedError
  end

  def positionable_scope_changed?
    false
  end
end
