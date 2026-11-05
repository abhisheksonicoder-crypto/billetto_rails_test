FactoryBot.define do
  factory :event do
    sequence(:billetto_id) { |n| "evt_#{n}" }
    title { "Evening at the hall" }
    description { "A short public event." }
    url { "https://billetto.dk/e/evening" }
    image_url { "https://billetto.imgix.net/evening" }
    starts_at { Time.zone.parse("2026-12-01 18:00") }
    ends_at { Time.zone.parse("2026-12-01 20:00") }
    state { "published" }
    city { "Copenhagen" }
    country_code { "DK" }
    category { "music" }
    organizer_name { "Billetto" }
  end
end
