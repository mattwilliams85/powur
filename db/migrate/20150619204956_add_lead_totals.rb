class AddLeadTotals < ActiveRecord::Migration
  def change
    create_table :lead_totals do |t|
      t.references :user, null: false
      t.references :product, null: false
      t.references :pay_period, type: :string
      t.integer :status, null: false
      t.integer :personal, null: false, default: 0
      t.integer :team, null: false, default: 0
    end

    add_index :lead_totals,
              [ :user_id, :product_id, :pay_period_id, :status ],
              unique: true,
              where:  'pay_period_id is not null',
              name:   'idx_lead_totals_not_null_pp'
    add_index :lead_totals,
              [ :user_id, :product_id, :status ],
              unique: true,
              where:  'pay_period_id is null',
              name:   'idx_lead_totals_null_pp'
  end
end
