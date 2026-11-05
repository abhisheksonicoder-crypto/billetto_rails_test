module Catalog
  class ImportPublicEvents
    attr_reader :filters

    def initialize(filters = {})
      @filters = filters.to_h
    end
  end
end
