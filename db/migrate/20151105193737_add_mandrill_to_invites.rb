class AddMandrillToInvites < ActiveRecord::Migration
  def change
    add_column :customers, :mandrill_id, :string
    add_column :invites, :mandrill_id, :string
  end
end
