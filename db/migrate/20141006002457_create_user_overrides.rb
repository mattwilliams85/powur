class CreateUserOverrides < ActiveRecord::Migration
  def change
    create_table :user_overrides do |t|
      t.references :user, null: false
      t.integer :type, null: false
      t.hstore :data, default: ''
      t.date :start_date
      t.date :end_date

      t.foreign_key :users
    end
  end
end
