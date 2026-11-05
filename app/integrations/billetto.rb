module Billetto
  class Error < StandardError
  end

  class ConfigurationError < Error
  end

  class RequestFailed < Error
    attr_reader :status

    def initialize(message, status: nil)
      @status = status
      super(message)
    end
  end

  class InvalidResponse < Error
  end
end
