class ResetBonuses0815 < ActiveRecord::Migration
  def change
    Rake::Task['powur:seed:bonuses'].invoke
  end
end
