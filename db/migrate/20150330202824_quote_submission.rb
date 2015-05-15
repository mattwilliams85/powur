class QuoteSubmission < ActiveRecord::Migration
  def change
    add_column :quotes, :submitted_at, :datetime
    add_column :quotes, :provider_uid, :string
  end
end
