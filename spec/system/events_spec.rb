require "rails_helper"

RSpec.describe "Event listing", type: :system do
  before { driven_by(:rack_test) }

  it "shows the imported event and keeps voting behind sign in" do
    event = create(:event, title: "Jazz in the courtyard", description: "Bring a friend.")

    visit events_path

    expect(page).to have_content("Jazz in the courtyard")
    expect(page).to have_content("Bring a friend.")
    expect(page).to have_button("Like 0")

    click_button "Like 0"

    expect(page).to have_current_path(sign_in_path)
    expect(page).to have_css("#sign-in")
    expect(page).to have_content("Sign in to vote on events.")
    expect(event.reload.upvote_count).to eq(0)
  end

  it "counts a like from a signed in user", clerk_user_id: "user_signed_in" do
    create(:event, title: "Workshop")

    visit events_path
    expect(page).to have_button("Log out")

    click_button "Like 0"

    expect(page).to have_button("Like 1")
    expect(page).to have_content("Vote recorded.")
  end

  it "renders Clerk sign up and sign out hooks" do
    original = ENV["CLERK_PUBLISHABLE_KEY"]
    ENV["CLERK_PUBLISHABLE_KEY"] = "pk_test_Y2xlcmsuZXhhbXBsZS5jb20k"

    visit sign_up_path
    expect(page).to have_css("#sign-up")

    visit sign_in_path
    expect(page).to have_css("#sign-in")
    expect(page.html).to include("@clerk/clerk-js@5")
    expect(page.html).to include("signOut")
  ensure
    ENV["CLERK_PUBLISHABLE_KEY"] = original
  end
end
