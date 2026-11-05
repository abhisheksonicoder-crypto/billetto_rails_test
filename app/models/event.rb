class Event < ApplicationRecord
  has_one :vote_tally, class_name: "EventVoteTally", dependent: :destroy
  has_many :votes, class_name: "EventVote", dependent: :destroy

  validates :billetto_id, :title, :starts_at, presence: true
  validates :billetto_id, uniqueness: true
  validates :url, :image_url, format: { with: %r{\Ahttps?://}i }, allow_blank: true
  validate :ends_at_not_before_start

  def upvote_count
    vote_tally&.upvotes.to_i
  end

  def downvote_count
    vote_tally&.downvotes.to_i
  end

  private

  def ends_at_not_before_start
    return if ends_at.blank? || starts_at.blank?
    return unless ends_at < starts_at

    errors.add(:ends_at, "must be on or after the start")
  end
end
