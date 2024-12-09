class RemoveContactIdFromEvents < ActiveRecord::Migration[7.1]
  def change
    remove_column :events, :contact_id, :integer
  end
end
