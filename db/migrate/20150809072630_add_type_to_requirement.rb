class AddTypeToRequirement < ActiveRecord::Migration
  def change
    add_column :user_group_requirements, :type, :string

    reversible do |dir|
      dir.up do
        UserGroupRequirement.where('event_type <> 1').update_all(type: 'LeadRequirement')
        UserGroupRequirement.where(event_type: 1).update_all(type: 'PurchaseRequirement')
      end
    end
  end
end
