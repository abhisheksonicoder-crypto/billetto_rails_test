require "rails_helper"

RSpec.describe Event, type: :model do
  subject(:event) { build(:event) }

  it "is valid with a title and a start time" do
    expect(event).to be_valid
  end

  it "requires a title" do
    event.title = " "
    expect(event).not_to be_valid
    expect(event.errors[:title]).to be_present
  end

  it "requires a start time" do
    event.starts_at = nil
    expect(event).not_to be_valid
  end

  it "rejects an end time before the start" do
    event.ends_at = event.starts_at - 1.hour
    expect(event).not_to be_valid
    expect(event.errors[:ends_at]).to include("must be on or after the start")
  end

  it "rejects a duplicate Billetto id" do
    event.save!
    duplicate = build(:event, billetto_id: event.billetto_id)
    expect(duplicate).not_to be_valid
  end

  it "rejects an image url that is not http" do
    event.image_url = "not-a-url"
    expect(event).not_to be_valid
  end
end
