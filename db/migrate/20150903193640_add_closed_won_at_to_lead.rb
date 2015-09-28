class AddClosedWonAtToLead < ActiveRecord::Migration
  def change
    unless column_exists?(:leads, :closed_won_at)
      add_column :leads, :closed_won_at, :datetime
    end

    closed_won_leads.each do |record|
      Lead
        .where(id: record.lead_id)
        .update_all(closed_won_at: record.updated_at)
    end
  end

  private

  def closed_won_leads
    LeadUpdate
      .select('lead_id, min(updated_at) updated_at')
      .where(opportunity_stage: 'Closed Won')
      .group(:lead_id)
  end
end
