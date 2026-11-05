class EventVoteTally < ApplicationRecord
  belongs_to :event

  validates :upvotes, :downvotes, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def apply_change(from:, to:)
    change(from, -1) if from.present?
    change(to, 1)
  end

  private

  def change(direction, amount)
    case direction
    when "up" then self.upvotes += amount
    when "down" then self.downvotes += amount
    end
  end
end
