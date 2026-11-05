require "rails_helper"

RSpec.describe "Votes", type: :request do
  let(:event) { create(:event) }

  it "redirects guests to sign in and does not record a vote" do
    post event_vote_path(event), params: { vote: { direction: "up" } }

    expect(response).to redirect_to(sign_in_path)
    expect(flash[:alert]).to eq("Sign in to vote on events.")
    expect(EventVote.count).to eq(0)
  end

  it "does not accept an invalid bearer token as a session" do
    post event_vote_path(event),
      params: { vote: { direction: "up" } },
      headers: { "Authorization" => "Bearer not-a-token" }

    expect(response).to redirect_to(sign_in_path)
    expect(EventVote.count).to eq(0)
  end

  it "records a vote for a Clerk user", clerk_user_id: "user_abc" do
    post event_vote_path(event), params: { vote: { direction: "up" } }

    expect(response).to redirect_to(events_path)
    expect(event.reload.upvote_count).to eq(1)
    stored = Rails.configuration.event_store.read.of_type(Catalog::EventUpvoted).to_a.last
    expect(stored.data[:user_id] || stored.data["user_id"]).to eq("user_abc")
  end

  it "rejects an unknown direction", clerk_user_id: "user_abc" do
    post event_vote_path(event), params: { vote: { direction: "sideways" } }

    expect(response).to redirect_to(events_path)
    expect(flash[:alert]).to be_present
    expect(event.reload.upvote_count).to eq(0)
  end
end
