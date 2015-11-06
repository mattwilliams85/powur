begin
  if ActiveRecord::Base.connection.tables.include?('settings')

    # SystemSettings.save_default(:max_invites, 5)
    SystemSettings.save_default(:invite_valid_days, 1)
    SystemSettings.save_default(:default_product_id, 1)
    SystemSettings.save_default(:min_rank, 0)
    SystemSettings.save_default(:case_sensitive_auth, false)
    SystemSettings.save_default(:first_monthly_pay_period, '2015-05')
    SystemSettings.save_default(:first_weekly_pay_period, '2015W28')

  end
rescue
  Rails.logger.info 'failed to set default settings, table not found'
end
