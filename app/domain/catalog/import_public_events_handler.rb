module Catalog
  class ImportPublicEventsHandler
    include ::EventStoreInjector

    def initialize(client: nil)
      @client = client
    end

    def call(command)
      result = ImportResult.new
      billetto.public_events(command.filters).each do |payload|
        ingest(payload, result)
      end
      result
    end

    private

    def ingest(payload, result)
      attributes = ::Billetto::PublicEventMapper.call(payload)
      contract = PublicEventContract.from(attributes)
      unless contract.valid?
        result.record(:rejected, billetto_id: attributes[:billetto_id], errors: contract.errors.full_messages)
        return
      end

      result.record(publish_change(attributes))
    rescue ::Billetto::InvalidResponse => error
      result.record(:rejected, errors: [ error.message ])
    end

    def publish_change(attributes)
      stream_name = "Catalog::PublicEvent$#{attributes.fetch(:billetto_id)}"
      last = event_store.read.stream(stream_name).backward.limit(1).to_a.first
      return :unchanged if last && same_payload?(last, attributes)

      fact_class = last ? PublicEventUpdated : PublicEventImported
      publish_fact(fact_class.strict(data: attributes))
      last ? :updated : :created
    end

    def same_payload?(fact, attributes)
      attributes.all? { |key, value| fact.value(key).to_s == value.to_s }
    end

    def billetto
      @client || Rails.configuration.billetto_client
    end
  end
end
