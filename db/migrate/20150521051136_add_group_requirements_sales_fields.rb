class AddGroupRequirementsSalesFields < ActiveRecord::Migration
  def change
    add_column :user_group_requirements, :time_span, :integer
    add_column :user_group_requirements, :max_leg, :integer
  end
end
