namespace :events do
  desc "Import public events from the Billetto API"
  task import: :environment do
    result = Rails.configuration.command_bus.call(Catalog::ImportPublicEvents.new)
    puts "created=#{result.created} updated=#{result.updated} unchanged=#{result.unchanged} rejected=#{result.rejected.size}"
    result.rejected.each do |rejection|
      puts "rejected billetto_id=#{rejection[:billetto_id]} errors=#{Array(rejection[:errors]).join(", ")}"
    end
  end
end
