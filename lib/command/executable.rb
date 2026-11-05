module Command
  module Executable
    extend ActiveSupport::Concern

    included do
      include ActiveModel::API
      include ActiveModel::Attributes
    end

    class_methods do
      def register(bus)
        bus.register(self, Dispatcher.new)
      end
    end
  end
end
