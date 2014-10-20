class CreateUserActivities < ActiveRecord::Migration
  def change
    create_table :user_activities do |t|
      t.references :user
      t.datetime :login_event

      t.timestamps
    end
  end
end
