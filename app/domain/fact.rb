class Fact < RubyEventStore::Event
  def self.strict(data:)
    normalized = data.to_h.symbolize_keys
    missing = schema.keys - normalized.keys
    raise ArgumentError, "#{name} is missing #{missing.join(", ")}" if missing.any?

    extra = normalized.keys - schema.keys
    raise ArgumentError, "#{name} has unknown attributes: #{extra.join(", ")}" if extra.any?

    schema.each do |key, type|
      value = normalized[key]
      raise ArgumentError, "#{name} #{key} must be a #{type}" unless value.is_a?(type)
    end

    new(data: normalized)
  end

  def self.schema
    self::SCHEMA
  end

  def value(key)
    return data[key] if data.key?(key)
    return data[key.to_s] if data.key?(key.to_s)

    nil
  end

  def stream_names
    raise NotImplementedError
  end
end
