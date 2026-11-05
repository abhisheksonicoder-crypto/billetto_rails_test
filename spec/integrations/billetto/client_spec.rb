require "rails_helper"

RSpec.describe Billetto::Client do
  subject(:client) do
    described_class.new(api_keypair: "key:secret", base_url: "https://billetto.dk/api/v3")
  end

  it "sends the key pair and returns the event rows" do
    stub_request(:get, "https://billetto.dk/api/v3/public/events")
      .with(headers: { "Api-Keypair" => "key:secret" }, query: hash_including("limit" => "100"))
      .to_return(
        status: 200,
        headers: { "Content-Type" => "application/json" },
        body: { "object" => "list", "data" => [ public_event_payload ], "has_more" => false }.to_json
      )

    expect(client.public_events).to eq([ public_event_payload ])
  end

  it "follows next_url while has_more is true" do
    stub_request(:get, "https://billetto.dk/api/v3/public/events")
      .with(query: hash_including("limit" => "100"))
      .to_return(
        status: 200,
        body: {
          "data" => [ public_event_payload ],
          "has_more" => true,
          "next_url" => "https://billetto.dk/api/v3/public/events?starting_after=1001"
        }.to_json
      )
    stub_request(:get, "https://billetto.dk/api/v3/public/events")
      .with(query: hash_including("starting_after" => "1001"))
      .to_return(
        status: 200,
        body: { "data" => [ public_event_payload("id" => "1002", "title" => "Second") ], "has_more" => false }.to_json
      )

    ids = client.public_events.map { |row| row["id"] }
    expect(ids).to eq(%w[1001 1002])
  end

  it "raises when the API responds with an error" do
    stub_request(:get, %r{billetto\.dk/api/v3/public/events}).to_return(status: 502, body: "bad gateway")

    expect { client.public_events }.to raise_error(Billetto::RequestFailed, /502/)
  end

  it "raises when the connection fails" do
    stub_request(:get, %r{billetto\.dk/api/v3/public/events}).to_timeout

    expect { client.public_events }.to raise_error(Billetto::RequestFailed)
  end

  it "raises when the body is not JSON" do
    stub_request(:get, %r{billetto\.dk/api/v3/public/events}).to_return(status: 200, body: "nope")

    expect { client.public_events }.to raise_error(Billetto::InvalidResponse)
  end

  it "raises when a page says there is more data but gives no next url" do
    stub_request(:get, %r{billetto\.dk/api/v3/public/events})
      .to_return(status: 200, body: { "data" => [], "has_more" => true }.to_json)

    expect { client.public_events }.to raise_error(Billetto::InvalidResponse, /next_url/)
  end

  it "raises when the key pair is missing" do
    client = described_class.new(api_keypair: "", base_url: "https://billetto.dk/api/v3")

    expect { client.public_events }.to raise_error(Billetto::ConfigurationError)
  end

  it "joins the key and secret from the environment" do
    ENV["BILLETTO_API_KEY"] = "access"
    ENV["BILLETTO_API_SECRET"] = "hidden"
    ENV.delete("BILLETTO_API_KEYPAIR")

    expect(described_class.keypair_from_env).to eq("access:hidden")
  ensure
    ENV.delete("BILLETTO_API_KEY")
    ENV.delete("BILLETTO_API_SECRET")
  end
end
