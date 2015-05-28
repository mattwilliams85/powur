class LeadUpdateColumns < ActiveRecord::Migration
  def change
    add_column :lead_updates, :lead_status, :string
    add_column :lead_updates, :opportunity_stage, :string
  end
end
