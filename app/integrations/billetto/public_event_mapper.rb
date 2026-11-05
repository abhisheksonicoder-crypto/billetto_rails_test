module Billetto
  class PublicEventMapper
    def self.call(payload)
      raise InvalidResponse, "public event payload must be an object" unless payload.is_a?(Hash)

      id = payload["id"] || payload[:id]
      raise InvalidResponse, "public event is missing an id" if id.blank?

      {
        billetto_id: id.to_s.strip,
        title: payload["title"].to_s.strip,
        description: payload["description"].to_s,
        url: payload["url"].to_s,
        image_url: (payload["image_link"] || payload["image_url"]).to_s,
        starts_at: payload["startdate"].to_s,
        ends_at: payload["enddate"].to_s,
        state: payload["state"].to_s,
        city: payload.dig("location", "city").to_s,
        country_code: payload.dig("location", "country_code").to_s,
        category: payload.dig("categorisation", "category").to_s,
        organizer_name: payload.dig("organizer", "name").to_s
      }
    end
  end
end
