begin
  PromoterConfig.max_invites = 5
  PromoterConfig.invite_valid_days = 1
rescue Exception# ActiveRecord::StatementInvalid, PG::UndefinableTable
end
