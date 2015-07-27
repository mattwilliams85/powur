begin
  if ActiveRecord::Base.connection.tables.include?('settings')

    SystemSettings.save_default(:max_invites, 5)
    SystemSettings.save_default(:invite_valid_days, 1)
    SystemSettings.save_default(:default_product_id, 1)
    SystemSettings.save_default(:min_rank, 1)
    SystemSettings.save_default(:case_sensitive_auth, false)

  end
rescue
  Rails.logger.info 'failed to set default settings, table not found'
end
