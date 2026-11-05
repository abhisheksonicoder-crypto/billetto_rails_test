module ReadModels
  class EventVoteProjection
    def call(fact)
      ApplicationRecord.transaction do
        return if ::ProcessedFact.exists?(fact_id: fact.event_id)

        event_id = fact.value(:event_id)
        user_id = fact.value(:user_id)
        direction = direction_for(fact)
        vote = ::EventVote.find_or_initialize_by(event_id: event_id, user_id: user_id)
        previous = vote.direction
        vote.direction = direction
        vote.save!

        tally = ::EventVoteTally.create_or_find_by!(event_id: event_id)
        tally.lock!
        tally.apply_change(from: previous, to: direction)
        tally.save!
        ::ProcessedFact.create!(fact_id: fact.event_id, fact_type: fact.event_type)
      end
    end

    private

    def direction_for(fact)
      case fact.event_type
      when ::Catalog::EventUpvoted.name then "up"
      when ::Catalog::EventDownvoted.name then "down"
      else
        raise ArgumentError, "unsupported vote fact #{fact.event_type}"
      end
    end
  end
end
