class UpdateMinRankAndBonuses < ActiveRecord::Migration
  def up
    SystemSettings.min_rank = 0
    # Rake::Task['powur:seed:bonuses'].invoke
    Bonus.reset_auto_id
  end
end
