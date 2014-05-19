class CreateInvites < ActiveRecord::Migration
  def change
    create_table :invites, id: false do |t|
      t.string :id
      t.string :email, null: false
      t.string :first_name, null: false
      t.string :last_name, null: false

      t.belongs_to :invitor, class_name: 'User', null: false
      t.belongs_to :invitee, class_name: 'User'

      t.timestamps
    end
    execute 'alter table invites add primary key (id);'
  end
end


# :primary_key, :column, :xml, :tsvector, :int4range, :int8range, :tsrange, :tstzrange, :numrange, 
# :daterange, :hstore, :ltree, :inet, :cidr, :macaddr, :uuid, :json, :indexes, :indexes=, :name, 
# :temporary, :options, :as, :columns, :[], :remove_column, :string, :text, :integer, :float, 
# :decimal, :datetime, :timestamp, :time, :date, :binary, :boolean, :index, :timestamps, :references, :belongs_to