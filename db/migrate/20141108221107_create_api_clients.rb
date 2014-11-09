class CreateApiClients < ActiveRecord::Migration
  def change
    create_table :api_clients, id: false do |t|
      t.string :id, null: false
      t.string :secret, null: false
    end
    execute 'alter table api_clients add primary key (id);'
  end
end
