class CreateContacts < ActiveRecord::Migration[7.1]
  def change
    create_table :contacts do |t|
      t.date :date_first_met
      t.string :current_employer
      t.string :partner
      t.date :most_recent_contact_date
      t.integer :communication_frequency
      t.string :industry
      t.string :role
      t.string :user_id
      t.string :integer
      t.string :introduced_by_id
      t.string :how_met
      t.string :notes

      t.timestamps
    end
  end
end
