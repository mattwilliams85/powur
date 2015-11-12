class RewardBonusChanges < ActiveRecord::Migration
  DEPRECATED_BONUSES = [ 4, 6 ]
  CHANGED_BONUSES = [ 3 ]
  NEW_BONUSES = [ 10 ]

  def up
    ids = DEPRECATED_BONUSES + CHANGED_BONUSES + NEW_BONUSES
    Bonus.update_attrs! do |attrs|
      ids.include?(attrs['id'])
    end

    create_table :user_codes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :bonus, null: false, foreign_key: true
      t.integer :coded_to, null: false
      t.integer :sponsor_sequence, null: false
    end

    add_foreign_key :user_codes, :users, column: :coded_to
    add_index :user_codes, [ :user_id, :bonus_id ], unique: true
  end

  def down
    drop_table :user_codes

    Bonus
      .where(id: DEPRECATED_BONUSES)
      .update_all(end_date: nil)

    Bonus.where(id: NEW_BONUSES).destroy_all
  end
end
