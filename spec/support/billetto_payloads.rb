module BillettoPayloads
  def public_event_payload(overrides = {})
    {
      "id" => "1001",
      "title" => "Test Public Event",
      "description" => "This is a test event",
      "url" => "https://billetto.dk/e/test-public-event",
      "image_link" => "https://billetto.imgix.net/example",
      "state" => "published",
      "startdate" => "2026-12-01T17:00:00Z",
      "enddate" => "2026-12-01T19:00:00Z",
      "location" => { "city" => "Copenhagen", "country_code" => "DK" },
      "categorisation" => { "category" => "business" },
      "organizer" => { "name" => "Billetto" }
    }.merge(overrides)
  end
end
