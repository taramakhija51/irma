class ChangeUserIdToIntegerInContacts < ActiveRecord::Migration[6.0]
  def change
    # Use the USING clause to cast the user_id column to an integer
    change_column :contacts, :user_id, "integer USING user_id::integer"
  end
end
