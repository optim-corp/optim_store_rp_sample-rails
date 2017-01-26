class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.belongs_to :contract
      t.string :identifier, null: false
      t.boolean :active, default: true
      t.timestamps
      t.index :identifier, unique: true
    end
  end
end
