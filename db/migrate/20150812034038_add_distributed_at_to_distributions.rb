class AddDistributedAtToDistributions < ActiveRecord::Migration
  def change
    add_column :distributions, :distributed_at, :datetime
  end
end
