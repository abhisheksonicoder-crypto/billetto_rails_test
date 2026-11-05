module Catalog
  class PublicEventFact < ::Fact
    SCHEMA = {
      billetto_id: String,
      title: String,
      description: String,
      url: String,
      image_url: String,
      starts_at: String,
      ends_at: String,
      state: String,
      city: String,
      country_code: String,
      category: String,
      organizer_name: String
    }.freeze

    def stream_names
      [ "Catalog::PublicEvent$#{value(:billetto_id)}" ]
    end
  end
end
