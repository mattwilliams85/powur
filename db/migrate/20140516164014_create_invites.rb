class CreateInvites < ActiveRecord::Migration
  def change
    create_table :invites, id: false do |t|
      t.string :id,         null: false
      t.string :email,      null: false
      t.string :first_name, null: false
      t.string :last_name,  null: false
      t.string :phone
      t.datetime :expires, null: false
      t.timestamps null: false

      t.belongs_to :invitor, null: false
      t.belongs_to :invitee

      t.foreign_key :users, column: :invitor_id, primary_key: :id
      t.foreign_key :users, column: :invitee_id, primary_key: :id
    end
    execute 'alter table invites add primary key (id);'
  end
end


# preferred postgres
# rake db:structure:dump
# config.active_record.schema_format :sql

# rspec will use db:structure:load

# :primary_key, :column, :xml, :tsvector, :int4range, :int8range, :tsrange, :tstzrange, :numrange, 
# :daterange, :hstore, :ltree, :inet, :cidr, :macaddr, :uuid, :json, :indexes, :indexes=, :name, 
# :temporary, :options, :as, :columns, :[], :remove_column, :string, :text, :integer, :float, 
# :decimal, :datetime, :timestamp, :time, :date, :binary, :boolean, :index, :timestamps, :references, :belongs_to