class ProcessedFact < ApplicationRecord
  validates :fact_id, :fact_type, presence: true
  validates :fact_id, uniqueness: true
end
