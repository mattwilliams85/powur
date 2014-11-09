class CreateApiTokens < ActiveRecord::Migration
  def change
    create_table :api_tokens, id: false do |t|
      t.string :id, null: false
      t.string :access_token, null: false
      t.string :client_id, null: false
      t.references :user, null: false
      t.datetime :expires_at, null: false

      t.foreign_key :api_clients, column: :client_id, primary_key: :id
      t.foreign_key :users
    end
    execute 'alter table api_tokens add primary key (id);'
    add_index :api_tokens, [ :access_token ], unique: true
  end
end
