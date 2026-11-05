require "rails_helper"

RSpec.describe Catalog::ImportPublicEvents do
  let(:bus) { Rails.configuration.command_bus }

  around do |example|
    previous = Rails.configuration.billetto_client
    example.run
  ensure
    Rails.configuration.billetto_client = previous
  end

  it "imports a valid event and does not publish it again" do
    Rails.configuration.billetto_client = Billetto::FakeClient.new(events: [ public_event_payload ])

    first = bus.call(described_class.new)
    second = bus.call(described_class.new)

    event = Event.find_by!(billetto_id: "1001")
    expect(first.created).to eq(1)
    expect(second.unchanged).to eq(1)
    expect(event.title).to eq("Test Public Event")
    expect(event.city).to eq("Copenhagen")
    expect(event.upvote_count).to eq(0)
    expect(Rails.configuration.event_store.read.of_type(Catalog::PublicEventImported).to_a.size).to eq(1)
  end

  it "publishes an update when the payload changes" do
    Rails.configuration.billetto_client = Billetto::FakeClient.new(events: [ public_event_payload ])
    bus.call(described_class.new)

    Rails.configuration.billetto_client = Billetto::FakeClient.new(
      events: [ public_event_payload("title" => "Renamed event") ]
    )
    result = bus.call(described_class.new)

    expect(result.updated).to eq(1)
    expect(Event.find_by!(billetto_id: "1001").title).to eq("Renamed event")
  end

  it "skips an invalid event and keeps the valid ones" do
    Rails.configuration.billetto_client = Billetto::FakeClient.new(
      events: [
        public_event_payload("id" => "bad", "title" => "", "enddate" => "2026-11-01T00:00:00Z"),
        public_event_payload
      ]
    )

    result = bus.call(described_class.new)

    expect(result.rejected.map { |row| row[:billetto_id] }).to eq([ "bad" ])
    expect(Event.pluck(:billetto_id)).to eq([ "1001" ])
  end

  it "rolls the fact back when the projection fails" do
    Rails.configuration.billetto_client = Billetto::FakeClient.new(events: [ public_event_payload ])
    allow_any_instance_of(ReadModels::PublicEventProjection).to receive(:call).and_raise(RuntimeError, "boom")

    expect {
      expect { bus.call(described_class.new) }.to raise_error(RuntimeError, "boom")
    }.not_to change(Event, :count)

    expect(Rails.configuration.event_store.read.to_a).to be_empty
  end
end
