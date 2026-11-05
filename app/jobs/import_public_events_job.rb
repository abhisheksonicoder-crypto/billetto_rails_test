class ImportPublicEventsJob < ApplicationJob
  queue_as :default

  retry_on Billetto::RequestFailed, wait: :polynomially_longer, attempts: 5
  discard_on Billetto::ConfigurationError

  def perform(filters = {})
    command_bus.call(Catalog::ImportPublicEvents.new(filters))
  end

  private

  def command_bus
    Rails.configuration.command_bus
  end
end
