class AddMessageToApplicationAgreements < ActiveRecord::Migration
  def change
    add_column :application_agreements, :message, :text
  end
end
