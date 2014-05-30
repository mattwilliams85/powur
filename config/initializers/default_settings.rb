begin
  if ActiveRecord::Base.connection.tables.include?('settings')
    PromoterConfig.max_invites = 5
    PromoterConfig.invite_valid_days = 1
  end
rescue Exception# ActiveRecord::StatementInvalid, PG::UndefinableTable
end
