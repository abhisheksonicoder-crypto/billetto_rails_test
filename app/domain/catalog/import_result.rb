module Catalog
  class ImportResult
    attr_reader :created, :updated, :unchanged, :rejected

    def initialize
      @created = 0
      @updated = 0
      @unchanged = 0
      @rejected = []
    end

    def record(outcome, billetto_id: nil, errors: nil)
      case outcome
      when :created then @created += 1
      when :updated then @updated += 1
      when :unchanged then @unchanged += 1
      when :rejected then @rejected << { billetto_id: billetto_id, errors: errors }
      end
    end
  end
end
