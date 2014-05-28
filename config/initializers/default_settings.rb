begin
  PromoterConfig.max_invites = 5
rescue ActiveRecord::StatementInvalid
end
