module Catalog
  class DownvoteEvent
    include ::Command::Executable

    attribute :event_id, :string
    attribute :user_id, :string

    validates :event_id, :user_id, presence: true
    validates :user_id, format: { with: /\A[A-Za-z0-9_]+\z/ }, allow_blank: true

    def call
      VoteCaster.new.call(event_id: event_id, user_id: user_id, direction: "down")
    end
  end
end
