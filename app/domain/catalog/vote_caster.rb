module Catalog
  class VoteCaster
    include ::EventStoreInjector

    def call(event_id:, user_id:, direction:)
      event = ::Event.find(event_id)
      return if current_direction(event.id, user_id) == direction

      fact_class = direction == "up" ? EventUpvoted : EventDownvoted
      publish_fact(fact_class.strict(data: { event_id: event.id.to_s, user_id: user_id }))
    end

    private

    def current_direction(event_id, user_id)
      last = event_store.read.stream("Catalog::Vote$#{event_id}$#{user_id}").backward.limit(1).to_a.first
      return if last.nil?

      last.event_type == EventUpvoted.name ? "up" : "down"
    end
  end
end
