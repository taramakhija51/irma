class AddFirstNameLastNameToContacts < ActiveRecord::Migration[7.1]
  def change
    add_column :contacts, :first_name, :string
    add_column :contacts, :last_name, :string
  end
end
