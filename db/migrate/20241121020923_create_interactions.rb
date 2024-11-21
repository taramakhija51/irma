class CreateInteractions < ActiveRecord::Migration[7.1]
  def change
    create_table :interactions do |t|
      t.integer :contact_id
      t.integer :event_id

      t.timestamps
    end
  end
end
