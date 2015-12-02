class MigrateCustomersDataIntoLeads < ActiveRecord::Migration
  def up
    Rake::Task['powur:customer_to_lead'].invoke
  end
end
