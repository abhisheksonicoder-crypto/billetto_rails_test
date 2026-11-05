types = [ Catalog::EventUpvoted, Catalog::EventDownvoted ]
ProcessedFact.where(fact_type: types.map(&:name)).delete_all
EventVote.delete_all
EventVoteTally.update_all(upvotes: 0, downvotes: 0)

projection = ReadModels::EventVoteProjection.new
Rails.configuration.event_store.read.of_type(types).each do |fact|
  projection.call(fact)
end
