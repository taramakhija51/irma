class AddEmbeddingToContacts < ActiveRecord::Migration[7.1]
  def change
    add_column :contacts, :embedding, :text
  end
end
