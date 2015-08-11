class BonusChanges < ActiveRecord::Migration
  def change
    add_column :bonuses, :amount, :decimal, precision: 10, scale: 2

    create_table :bonus_payment_leads, id: false do |t|
      t.references :bonus_payment, null: false
      t.references :lead, null: false

      t.foreign_key :bonus_payments
      t.foreign_key :leads
    end

    reversible do |dir|
      dir.up do
        execute '
          alter table bonus_payment_leads
          add primary key (bonus_payment_id, lead_id);'

        [ :bonus_plan_id, :flat_amount, :product_id ].each do |column|
          remove_column(:bonuses, column) if column_exists?(:bonuses, column)
        end

        if column_exists? :bonus_amounts, :rank_path_id
          remove_column :bonus_amounts, :rank_path_id
        end

        if table_exists?(:bonus_payment_orders)
          drop_table(:bonus_payment_orders)
        end
      end
    end
  end
end
