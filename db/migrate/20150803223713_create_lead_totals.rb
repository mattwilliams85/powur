class CreateLeadTotals < ActiveRecord::Migration
  def change
    create_table :lead_totals do |t|
      t.references :user, null: false
      t.references :pay_period, type: :string, null: false
      t.integer :status, null: false
      t.integer :personal, null: false, default: 0
      t.integer :team, null: false, default: 0
      t.integer :personal_lifetime, null: false, default: 0
      t.integer :team_lifetime, null: false, default: 0
      t.integer :smaller_legs, null: false, default: 0
    end

    add_index :lead_totals,
              [ :user_id, :pay_period_id, :status ],
              unique: true
  end
end
