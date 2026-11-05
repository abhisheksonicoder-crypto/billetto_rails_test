class CreateEventVotes < ActiveRecord::Migration[8.1]
  def change
    create_table :event_votes do |t|
      t.references :event, null: false, foreign_key: true
      t.string :user_id, null: false
      t.string :direction, null: false
      t.timestamps
    end

    add_index :event_votes, [ :event_id, :user_id ], unique: true
    add_check_constraint :event_votes, "direction IN ('up', 'down')", name: "event_votes_direction"
  end
end
