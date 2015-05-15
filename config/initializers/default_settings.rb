begin
  if ActiveRecord::Base.connection.tables.include?('settings')

    SystemSettings.save_default(:max_invites, 5)
    SystemSettings.save_default(:invite_valid_days, 1)
    SystemSettings.save_default(:default_product_id, 1)
    SystemSettings.save_default(:min_rank, 1)

  end
rescue Exception
end
