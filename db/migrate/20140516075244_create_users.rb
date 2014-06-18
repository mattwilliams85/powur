class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string    :email, null: false
      t.string    :encrypted_password, null: false
      t.string    :first_name, null: false
      t.string    :last_name, null: false
      t.string    :phone
      t.string    :zip
      t.string    :url_slug
      t.string    :reset_token
      t.datetime  :reset_sent_at
      t.timestamps null: false

      t.belongs_to :sponsor, index: true
      t.integer :upline, array: true, default: []

      t.foreign_key :users, column: :sponsor_id, primary_key: :id
    end

    add_index :users, :upline, using: 'gin'
    add_index :users, [ :email ], unique: true
    add_index :users, [ :url_slug ], unique: true
  end
end
