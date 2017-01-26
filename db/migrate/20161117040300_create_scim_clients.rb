class CreateScimClients < ActiveRecord::Migration[5.0]
  def change
    create_table :scim_clients do |t|
      t.belongs_to :contract
      t.string :identifier, null: false
      t.string :secret, null: false
      t.timestamps
      t.index :identifier, unique: true
    end
  end
end
