# Billetto events

A small Rails application that imports public events from the Billetto API, lists them, and records likes and dislikes. Voting is event-sourced with [Rails Event Store](https://railseventstore.org/) and limited to people signed in with [Clerk](https://clerk.com/).

## Setup

Ruby 3.3 and PostgreSQL are required.

```bash
bundle install
bin/rails db:prepare
bin/rails server
```

Copy the variables you need into the environment before importing or signing in:

```bash
export BILLETTO_API_KEYPAIR="your_key:your_secret"
export BILLETTO_API_BASE_URL="https://billetto.dk/api/v3" # optional, this is the default
export CLERK_PUBLISHABLE_KEY="pk_test_..."
export CLERK_SECRET_KEY="sk_test_..."
```

`BILLETTO_API_KEY` and `BILLETTO_API_SECRET` are accepted in place of `BILLETTO_API_KEYPAIR`. The client sends them as the `Api-Keypair` header (`key:secret`). Create the pair from a Billetto organiser account under Developers.

Import the catalog:

```bash
bin/rails events:import
```

`bin/rails db:seed` loads two sample events through the same import command, without calling Billetto.

## What you can do

- Open `/` to see title, date, image, and a short description.
- Sign up and sign in at `/sign_up` and `/sign_in`. Clerk's browser SDK renders those screens when the keys above are set.
- Like or dislike an event. The buttons are refused until Clerk has a session.
- In development, `/res` is the Rails Event Store browser.

## Design

The write side is a small command bus. Controllers only build a command and send it. The bus runs the handler inside a database transaction, records a `command.bus` notification, and stamps correlation and causation ids onto every fact published from that command.

`Catalog::ImportPublicEvents` asks the Billetto client for public events, checks each payload, and publishes `Catalog::PublicEventImported` or `Catalog::PublicEventUpdated`. An unchanged payload is not published again. Invalid rows are skipped and reported by the rake task. HTTP failures raise `Billetto::RequestFailed` and do not write a partial page.

`Catalog::UpvoteEvent` and `Catalog::DownvoteEvent` publish `Catalog::EventUpvoted` or `Catalog::EventDownvoted`. Each fact is stored on the vote stream `Catalog::Vote$<event_id>$<user_id>` and linked to the event stream and the user stream. A second vote in the same direction publishes nothing. Switching direction publishes the new fact. The user id stored on the fact is the Clerk user id (`sub`).

The events table and the vote tallies are read models. `ReadModels::PublicEventProjection` and `ReadModels::EventVoteProjection` run in the same transaction as the command, so the listing shows the vote that was just cast. Both projections ignore a fact they have already applied (`processed_facts.fact_id`), which makes a rebuild safe:

```bash
bin/rails runner script/rebuild_public_events.rb
bin/rails runner script/rebuild_event_votes.rb
```

The Billetto HTTP client lives in `app/integrations/billetto`. The test environment uses `Billetto::FakeClient`, so the suite does not call the API. The real client's error mapping is covered with WebMock.

## Assumptions

- The public events endpoint is `GET /api/v3/public/events` on `https://billetto.dk`, with `limit`, `has_more`, and `next_url` pagination. The base URL is configurable for other Billetto regions.
- Optional API fields are stored as empty strings on the fact. The read model turns blanks back into `nil`.
- One person has one current vote per event.
- Clerk's development keys (`sk_test_`) redirect the first browser request through Clerk's handshake. That is the SDK middleware, and it needs the real keys. Until those keys are present, the app still boots and the event list is public. Voting still requires a Clerk user id.
- Sign-up, sign-in, and log out are Clerk's browser components. The system specs drive the server-rendered pages and the vote restriction. They do not complete Clerk's hosted handshake, because that needs a Clerk instance.
- There is no polymorphic object repository. Stream names carry the id of the event or the user.

## Tests

```bash
bundle exec rspec
bin/rubocop
```
