class SeedLeadActions < ActiveRecord::Migration
  def up
    Rake::Task['powur:seed:lead_actions'].invoke
  end
end
