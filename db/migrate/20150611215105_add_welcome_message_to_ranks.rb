class AddWelcomeMessageToRanks < ActiveRecord::Migration
  def change
    add_column :ranks, :welcome_message, :text
  end
end
