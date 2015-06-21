class CreateLeads < ActiveRecord::Migration
  def reset_id_sequence
    sql = 'select id from leads order by id desc limit 1;'
    result = execute(sql)
    next_id = result.first['id'].to_i + 1
    sql = "alter sequence leads_id_seq restart with #{next_id}"
    execute(sql)
  end

  def migrate_quotes
    Quote.all.each do |quote|
      attrs = {
        user_id:      quote.user_id,
        product_id:   quote.product_id,
        customer_id:  quote.customer_id,
        data:         quote.data,
        status:       Quote.statuses[quote.status],
        submitted_at: quote.submitted_at,
        provider_uid: quote.provider_uid,
        created_at:   quote.created_at,
        updated_at:   quote.updated_at }

      Lead.create!(attrs)
    end
  end

  def change
    create_table :leads do |t|
      t.references :user, null: false
      t.references :product, null: false
      t.references :customer, null: false
      t.hstore :data, default: '', null: false
      t.integer :status, null: false, default: 0
      t.datetime :submitted_at
      t.string :provider_uid
      t.datetime :qualified_at
      t.datetime :contract_at
      t.datetime :install_at

      t.timestamps null: false
    end

    add_index :leads, [ :user_id, :status ]

    reversible do |dir|
      dir.up do
        migrate_quotes
        reset_id_sequence
      end
    end
  end
end
