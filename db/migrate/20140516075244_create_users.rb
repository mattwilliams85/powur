class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string     :email, null: false
      t.string     :encrypted_password, null: false
      t.string     :first_name, null: false
      t.string     :last_name, null: false
      t.hstore     :contact, default: ''
      t.string     :url_slug
      t.string     :reset_token
      t.datetime   :reset_sent_at
      t.string     :roles, array: true, default: []
      t.integer    :upline, array: true, default: []
      t.integer    :lifetime_rank
      t.integer    :organic_rank
      t.references :rank_path
      t.references :sponsor, index: true
      t.timestamps null: false

      t.foreign_key :ranks, column: :lifetime_rank, primary_key: :id
      t.foreign_key :ranks, column: :organic_rank, primary_key: :id
      t.foreign_key :rank_paths
      t.foreign_key :users, column: :sponsor_id, primary_key: :id
    end

    add_index :users, :upline, using: 'gin'
    add_index :users, [ :email ], unique: true
    add_index :users, [ :url_slug ], unique: true
  end
end
