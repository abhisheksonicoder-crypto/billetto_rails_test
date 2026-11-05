class ApplicationSubscriptions
  def call(event_store, command_bus)
    event_store.subscribe_to_all_events(RubyEventStore::LinkByEventType.new(event_store: event_store))
    event_store.subscribe_to_all_events(RubyEventStore::LinkByCorrelationId.new(event_store: event_store))
    event_store.subscribe_to_all_events(RubyEventStore::LinkByCausationId.new(event_store: event_store))

    Catalog.subscriptions.each do |handler, events|
      event_store.subscribe(handler, to: events)
    end

    Catalog.register_commands(command_bus)
  end
end
