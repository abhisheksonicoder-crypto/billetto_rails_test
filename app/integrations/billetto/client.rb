module Billetto
  class Client
    FILTERS = %w[postal_code macroregion region subregion organizer_id type category subcategory].freeze
    MAX_PAGES = 25
    DEFAULT_BASE_URL = "https://billetto.dk/api/v3"

    def self.build
      return FakeClient.new if ::Rails.env.test?

      new(
        api_keypair: keypair_from_env,
        base_url: ENV.fetch("BILLETTO_API_BASE_URL", DEFAULT_BASE_URL)
      )
    end

    def self.keypair_from_env
      return ENV["BILLETTO_API_KEYPAIR"] if ENV["BILLETTO_API_KEYPAIR"].present?

      key = ENV["BILLETTO_API_KEY"]
      secret = ENV["BILLETTO_API_SECRET"]
      return if key.blank? || secret.blank?

      "#{key}:#{secret}"
    end

    def initialize(api_keypair:, base_url:, page_size: 100, http: nil)
      @api_keypair = api_keypair.to_s
      @base_url = base_url
      @page_size = page_size
      @http = http || Faraday.new(url: base_url) { |connection|
        connection.options.timeout = 10
        connection.options.open_timeout = 5
      }
    end

    def public_events(filters = {})
      raise ConfigurationError, "Set BILLETTO_API_KEYPAIR or BILLETTO_API_KEY and BILLETTO_API_SECRET" if api_keypair.blank?

      collected = []
      path = "public/events"
      params = sanitize_filters(filters).merge("limit" => page_size)
      visited = {}
      pages = 0

      loop do
        pages += 1
        raise InvalidResponse, "public events pagination exceeded #{MAX_PAGES} pages" if pages > MAX_PAGES

        page = get_json(path, params)
        rows = page["data"] || page[:data]
        raise InvalidResponse, "public events response is missing data" unless rows.is_a?(Array)

        collected.concat(rows)
        break unless more?(page["has_more"].nil? ? page[:has_more] : page["has_more"])

        nxt = page["next_url"] || page[:next_url]
        raise InvalidResponse, "public events response has more pages but no next_url" if nxt.blank?
        raise InvalidResponse, "public events pagination repeated #{nxt}" if visited[nxt]

        visited[nxt] = true
        path = nxt
        params = nil
      end

      collected
    end

    private

    attr_reader :api_keypair, :page_size, :http

    def sanitize_filters(filters)
      filters.to_h.stringify_keys.slice(*FILTERS).compact_blank
    end

    def more?(value)
      value == true || value.to_s == "true"
    end

    def request_json(path, params)
      http.get(path, params) do |request|
        request.headers["Api-Keypair"] = api_keypair
        request.headers["Accept"] = "application/json"
      end
    end

    def get_json(path, params)
      response = request_json(path, params)

      unless response.success?
        raise RequestFailed.new("Billetto responded with HTTP #{response.status}", status: response.status)
      end

      JSON.parse(response.body)
    rescue Faraday::Error => error
      raise RequestFailed, error.message
    rescue JSON::ParserError => error
      raise InvalidResponse, error.message
    end
  end
end
