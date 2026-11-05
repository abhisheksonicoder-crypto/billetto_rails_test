class CreateProcessedFacts < ActiveRecord::Migration[8.1]
  def change
    create_table :processed_facts do |t|
      t.string :fact_id, null: false
      t.string :fact_type, null: false
      t.timestamps
    end

    add_index :processed_facts, :fact_id, unique: true
  end
end
