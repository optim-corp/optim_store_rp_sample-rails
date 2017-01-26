class CreateTokens < ActiveRecord::Migration[5.0]
  def change
    create_table :tokens do |t|
      t.belongs_to :client
      t.string :access_token
      t.timestamps
      t.index :access_token, unique: true
    end
  end
end
