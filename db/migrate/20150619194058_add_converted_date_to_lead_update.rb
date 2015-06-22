class AddConvertedDateToLeadUpdate < ActiveRecord::Migration
  def change
    add_column :lead_updates, :converted, :datetime
  end
end
