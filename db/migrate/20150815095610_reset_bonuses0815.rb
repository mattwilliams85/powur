class ResetBonuses0815 < ActiveRecord::Migration
  def up
    Rake::Task['powur:seed:bonuses'].invoke
    Bonus.find(7).destroy
    Rake::Task['powur:overrides:ranks'].invoke
    LeadRequirement.monthly.update_all(max_leg: 50)
    LeadTotals.calculate_all!
    Rank.rank_users!
    u = User.find(42)
    u.roles << :breakage_account
    u.save!
  end
end
