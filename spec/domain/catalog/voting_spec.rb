require "rails_helper"

RSpec.describe "Voting" do
  let(:bus) { Rails.configuration.command_bus }
  let(:event_store) { Rails.configuration.event_store }
  let(:event) { create(:event) }
  let(:user_id) { "user_123" }

  def upvote
    bus.call(Catalog::UpvoteEvent.new(event_id: event.id.to_s, user_id: user_id))
  end

  def downvote
    bus.call(Catalog::DownvoteEvent.new(event_id: event.id.to_s, user_id: user_id))
  end

  it "records an upvote for the user and counts it once" do
    upvote
    upvote

    expect(event.reload.upvote_count).to eq(1)
    expect(event.downvote_count).to eq(0)

    vote_stream = event_store.read.stream("Catalog::Vote$#{event.id}$#{user_id}").to_a
    expect(vote_stream.map(&:event_type)).to eq([ Catalog::EventUpvoted.name ])
    expect(vote_stream.first.value(:event_id)).to eq(event.id.to_s)
    expect(vote_stream.first.value(:user_id)).to eq(user_id)
    expect(vote_stream.first.metadata[:correlation_id]).to be_present
    expect(event_store.read.stream("Catalog::User$#{user_id}").to_a.map(&:event_id)).to eq([ vote_stream.first.event_id ])
    expect(event_store.read.stream("Catalog::Event$#{event.id}").to_a.map(&:event_id)).to eq([ vote_stream.first.event_id ])
  end

  it "moves the count when the user switches to a dislike" do
    upvote
    downvote
    downvote

    expect(event.reload.upvote_count).to eq(0)
    expect(event.downvote_count).to eq(1)
    expect(EventVote.find_by!(event: event, user_id: user_id).direction).to eq("down")
    expect(event_store.read.stream("Catalog::Vote$#{event.id}$#{user_id}").to_a.map(&:event_type)).to eq(
      [ Catalog::EventUpvoted.name, Catalog::EventDownvoted.name ]
    )
  end

  it "refuses a vote without a user id" do
    expect {
      bus.call(Catalog::UpvoteEvent.new(event_id: event.id.to_s, user_id: ""))
    }.to raise_error(ActiveModel::ValidationError)
    expect(event.reload.upvote_count).to eq(0)
  end
end
