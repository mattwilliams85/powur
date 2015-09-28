class ResetBonuses0815 < ActiveRecord::Migration
  def up
    Rake::Task['powur:seed:bonuses'].invoke
    bonus = Bonus.find_by(id: 7)
    bonus && bonus.destroy
    Rake::Task['powur:overrides:ranks'].invoke
    LeadRequirement.monthly.update_all(max_leg: 50)
    LeadTotals.calculate_all!
    Rank.rank_users!
    u = User.find_by(id: 42)
    return unless u
    u.roles << :breakage_account
    u.save!
  end
end
