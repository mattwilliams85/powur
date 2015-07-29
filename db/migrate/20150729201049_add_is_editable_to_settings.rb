class AddIsEditableToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :is_editable, :boolean

    SystemSettings.create(
      var:         'twilio_account_sid',
      value:       '',
      is_editable: true)

    SystemSettings.create(
      var:         'twilio_auth_token',
      value:       '',
      is_editable: true)
  end
end
