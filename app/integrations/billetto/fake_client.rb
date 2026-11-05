module Billetto
  class FakeClient
    def initialize(events: [])
      @events = events
    end

    def public_events(_filters = {})
      events.map(&:deep_dup)
    end

    private

    attr_reader :events
  end
end
