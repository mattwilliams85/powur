class CreateLeadActions < ActiveRecord::Migration
  def change
    create_table :lead_actions do |t|
      t.integer :completion_chance
      t.integer :data_status
      t.string :lead_status
      t.string :opportunity_stage
      t.string :action_copy, null: false
    end
  end
end
