module Catalog
  class VoteFact < ::Fact
    SCHEMA = {
      event_id: String,
      user_id: String
    }.freeze

    def stream_names
      event_id = value(:event_id)
      user_id = value(:user_id)
      [
        "Catalog::Vote$#{event_id}$#{user_id}",
        "Catalog::Event$#{event_id}",
        "Catalog::User$#{user_id}"
      ]
    end
  end
end
