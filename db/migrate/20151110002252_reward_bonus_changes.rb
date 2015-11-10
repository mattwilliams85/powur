class RewardBonusChanges < ActiveRecord::Migration
  DEPRECATED_BONUSES = [ 4, 6 ]
  CHANGED_BONUSES = [ 2 ]
  NEW_BONUSES = [ 10 ]

  def up
    add_column :users, :coded_user_id, :integer
    add_foreign_key :users, :users, column: :coded_user_id

    ids = DEPRECATED_BONUSES + CHANGED_BONUSES + NEW_BONUSES
    Bonus.update_attrs! do |attrs|
      ids.include?(attrs['id'])
    end
  end

  def down
    Bonus
      .where(id: DEPRECATED_BONUSES)
      .update_all(end_date: nil)

    Bonus.where(id: NEW_BONUSES).destroy_all

    remove_column :users, :coded_user_id, :integer
  end
end
