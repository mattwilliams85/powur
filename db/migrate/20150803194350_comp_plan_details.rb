class CompPlanDetails < ActiveRecord::Migration
  def change
    Rake::Task['powur:seed:plan'].invoke
  end
end
