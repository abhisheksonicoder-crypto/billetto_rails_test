module Catalog
  class PublicEventContract
    include ActiveModel::API
    include ActiveModel::Attributes

    attribute :billetto_id, :string
    attribute :title, :string
    attribute :starts_at, :datetime
    attribute :ends_at, :datetime

    validates :billetto_id, :title, :starts_at, presence: true
    validate :ends_at_not_before_start

    def self.from(attributes)
      new(
        billetto_id: attributes[:billetto_id],
        title: attributes[:title],
        starts_at: parse_time(attributes[:starts_at]),
        ends_at: parse_time(attributes[:ends_at])
      )
    end

    def self.parse_time(value)
      return if value.blank?

      Time.zone.parse(value.to_s)
    rescue ArgumentError, TypeError
      nil
    end

    private

    def ends_at_not_before_start
      return if ends_at.blank? || starts_at.blank?
      return unless ends_at < starts_at

      errors.add(:ends_at, "must be on or after the start")
    end
  end
end
