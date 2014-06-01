class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string    :email, null: false
      t.string    :encrypted_password, null: false
      t.string    :first_name, null: false
      t.string    :last_name, null: false
      t.string    :phone
      t.string    :zip
      t.string    :reset_token
      t.datetime  :reset_sent_at

      t.timestamps
    end

    add_index :users, [ :email ], unique: true
  end
end
