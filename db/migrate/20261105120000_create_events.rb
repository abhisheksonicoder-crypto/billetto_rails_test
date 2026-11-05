class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.string :billetto_id, null: false
      t.string :title, null: false
      t.text :description
      t.text :url
      t.text :image_url
      t.datetime :starts_at, null: false
      t.datetime :ends_at
      t.string :state
      t.string :city
      t.string :country_code
      t.string :category
      t.string :organizer_name
      t.timestamps
    end

    add_index :events, :billetto_id, unique: true
    add_index :events, :starts_at
  end
end
