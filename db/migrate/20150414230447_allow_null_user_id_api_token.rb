class AllowNullUserIdApiToken < ActiveRecord::Migration
  def change
    change_column :api_tokens, :user_id, :integer, null: true
  end
end
