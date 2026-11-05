class CreateEventVoteTallies < ActiveRecord::Migration[8.1]
  def change
    create_table :event_vote_tallies do |t|
      t.references :event, null: false, foreign_key: true, index: { unique: true }
      t.integer :upvotes, null: false, default: 0
      t.integer :downvotes, null: false, default: 0
      t.timestamps
    end

    add_check_constraint :event_vote_tallies,
      "upvotes >= 0 AND downvotes >= 0",
      name: "event_vote_tallies_non_negative"
  end
end
