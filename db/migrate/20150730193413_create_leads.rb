class CreateLeads < ActiveRecord::Migration
  def reset_id_sequence
    sql = 'select id from leads order by id desc limit 1;'
    result = execute(sql)
    next_id = result.first['id'].to_i + 1
    sql = "alter sequence leads_id_seq restart with #{next_id}"
    execute(sql)
  end

  def last_update_attrs(quote)
    last_update = quote.last_update
    return {} unless last_update
    { sales_status: last_update.sales_status,
      converted_at: last_update.converted,
      contract_at:  last_update.contract,
      install_at:   last_update.installation }
  end

  def quote_attrs(quote)
    data_status =
      if quote.submitted_at?
        :submitted
      else
        Quote.statuses[quote.status]
      end

    { id:           quote.id,
      user_id:      quote.user_id,
      product_id:   quote.product_id,
      customer_id:  quote.customer_id,
      data:         quote.data,
      data_status:  data_status,
      provider_uid: quote.provider_uid,
      submitted_at: quote.submitted_at,
      created_at:   quote.created_at,
      updated_at:   quote.updated_at }.merge(last_update_attrs(quote))
  end

  def migrate_quotes
    Quote.all.each do |quote|
      attrs = quote_attrs(quote)

      Lead.create!(attrs)
    end
  end

  def change
    create_table :leads do |t|
      t.references :user, null: false
      t.references :product, null: false
      t.references :customer, null: false
      t.hstore :data, default: '', null: false
      t.integer :data_status, null: false, default: 0
      t.integer :sales_status, null: false, default: 0
      t.string :provider_uid
      t.datetime :submitted_at
      t.datetime :converted_at
      t.datetime :contract_at
      t.datetime :install_at

      t.timestamps null: false
    end

    add_index :leads, [ :user_id, :data_status ]
    add_index :leads, [ :user_id, :sales_status ]

    reversible do |dir|
      dir.up do
        migrate_quotes
        reset_id_sequence
      end
    end

    remove_foreign_key :lead_updates, :quotes
    rename_column :lead_updates, :quote_id, :lead_id
    add_reference :lead_updates, :leads, index: true, foreign_key: true
  end
end
