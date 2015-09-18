class AddSalesStatusToLeadAction < ActiveRecord::Migration
  def change
    add_column :lead_actions, :sales_status, :integer

    reversible do |dir|
      dir.up do
        Rake::Task['powur:seed:lead_actions'].invoke
      end
    end
  end
end
