module ReadModels
  class PublicEventProjection
    def call(fact)
      ApplicationRecord.transaction do
        return if ::ProcessedFact.exists?(fact_id: fact.event_id)

        event = ::Event.find_or_initialize_by(billetto_id: fact.value(:billetto_id))
        event.assign_attributes(attributes_for(fact))
        event.save!
        ::EventVoteTally.create_or_find_by!(event_id: event.id)
        ::ProcessedFact.create!(fact_id: fact.event_id, fact_type: fact.event_type)
      end
    end

    private

    def attributes_for(fact)
      ends_at = fact.value(:ends_at)
      {
        title: fact.value(:title),
        description: fact.value(:description).presence,
        url: fact.value(:url).presence,
        image_url: fact.value(:image_url).presence,
        starts_at: Time.zone.parse(fact.value(:starts_at).to_s),
        ends_at: ends_at.present? ? Time.zone.parse(ends_at.to_s) : nil,
        state: fact.value(:state).presence,
        city: fact.value(:city).presence,
        country_code: fact.value(:country_code).presence,
        category: fact.value(:category).presence,
        organizer_name: fact.value(:organizer_name).presence
      }
    end
  end
end
