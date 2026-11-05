sample = [
  {
    "id" => "seed-1001",
    "title" => "Jazz in the courtyard",
    "description" => "An early evening of quartet jazz.",
    "url" => "https://billetto.dk/e/jazz-in-the-courtyard",
    "image_link" => "https://billetto.imgix.net/jazz",
    "state" => "published",
    "startdate" => "2026-12-03T17:00:00Z",
    "enddate" => "2026-12-03T19:00:00Z",
    "location" => { "city" => "Copenhagen", "country_code" => "DK" },
    "categorisation" => { "category" => "music" },
    "organizer" => { "name" => "Courtyard Hall" }
  },
  {
    "id" => "seed-1002",
    "title" => "Product design workshop",
    "description" => "A practical session on shaping a small product.",
    "url" => "https://billetto.dk/e/product-design-workshop",
    "image_link" => "https://billetto.imgix.net/workshop",
    "state" => "published",
    "startdate" => "2026-12-10T09:00:00Z",
    "enddate" => "2026-12-10T12:00:00Z",
    "location" => { "city" => "Aarhus", "country_code" => "DK" },
    "categorisation" => { "category" => "business" },
    "organizer" => { "name" => "Studio North" }
  }
]

begin
  previous = Rails.configuration.billetto_client
  Rails.configuration.billetto_client = Billetto::FakeClient.new(events: sample)
  Rails.configuration.command_bus.call(Catalog::ImportPublicEvents.new)
ensure
  Rails.configuration.billetto_client = previous
end
