class CreateEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :events do |t|
      t.string :event_type
      t.date :event_date
      t.string :event_location
      t.integer :contact_id
      t.integer :user_id
      t.string :intention

      t.timestamps
    end
  end
end
