module Catalog
  def self.subscriptions
    {
      ::ReadModels::PublicEventProjection.new => [ PublicEventImported, PublicEventUpdated ],
      ::ReadModels::EventVoteProjection.new => [ EventUpvoted, EventDownvoted ]
    }
  end

  def self.register_commands(bus)
    bus.register(ImportPublicEvents, ImportPublicEventsHandler.new)
    UpvoteEvent.register(bus)
    DownvoteEvent.register(bus)
  end
end
