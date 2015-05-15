class LeadUpdates < ActiveRecord::Migration
  def change
    create_table :lead_updates do |t|
      t.references :quote, null: false
      t.string :provider_uid, null: false
      t.string :status, null: false
      t.hstore :contact, default: ''
      t.hstore :order_status, default: ''
      t.datetime :consultation
      t.datetime :contract
      t.datetime :installation
      t.datetime :created_at, null: false

      t.foreign_key :quotes
    end
  end
end
