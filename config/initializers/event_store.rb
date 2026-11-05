Rails.application.config.to_prepare do
  Rails.configuration.event_store = RailsEventStore::JSONClient.new
  Rails.configuration.command_bus = Command::Bus.new
  Rails.configuration.billetto_client = Billetto::Client.build

  ApplicationSubscriptions.new.call(
    Rails.configuration.event_store,
    Rails.configuration.command_bus
  )
end
