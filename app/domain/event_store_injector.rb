module EventStoreInjector
  def event_store
    Rails.configuration.event_store
  end

  def publish_fact(fact)
    streams = fact.stream_names
    event_store.publish(fact, stream_name: streams.first)
    streams.drop(1).each do |stream_name|
      event_store.link(fact.event_id, stream_name: stream_name)
    end
    fact
  end
end
