types = [ Catalog::PublicEventImported, Catalog::PublicEventUpdated ]
ProcessedFact.where(fact_type: types.map(&:name)).delete_all

projection = ReadModels::PublicEventProjection.new
Rails.configuration.event_store.read.of_type(types).each do |fact|
  projection.call(fact)
end
