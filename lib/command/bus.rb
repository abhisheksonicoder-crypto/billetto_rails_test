module Command
  class Bus
    def initialize
      @handlers = {}
    end

    def register(command_class, handler)
      @handlers[command_class] = handler
    end

    def call(command)
      handler = @handlers.fetch(command.class) do
        raise KeyError, "No handler registered for #{command.class}"
      end

      ActiveRecord::Base.transaction do
        event_store.with_metadata(command_metadata) do
          ActiveSupport::Notifications.instrument("command.bus", command: command.class.name) do
            handler.call(command)
          end
        end
      end
    end

    private

    def event_store
      Rails.configuration.event_store
    end

    def command_metadata
      command_id = SecureRandom.uuid
      { correlation_id: command_id, causation_id: command_id }
    end
  end
end
