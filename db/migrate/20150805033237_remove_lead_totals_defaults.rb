class RemoveLeadTotalsDefaults < ActiveRecord::Migration
  def up
    [ :personal, :personal_lifetime, :team, :team_lifetime ].each do |field|
      change_column_default :lead_totals, field, nil
    end
  end
end
