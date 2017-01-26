class CreateContracts < ActiveRecord::Migration[5.0]
  def change
    create_table :contracts do |t|
      t.string :identifier, null: false
      t.text :their_public_key, null: false
      t.text :our_private_key, null: false
      t.integer :license_pool, null: false
      t.timestamps
      t.index :identifier, unique: true
    end
  end
end
