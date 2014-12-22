earnings_json.item_init(local_assigns[:rel] || 'earning')

earnings_json.list_item_properties(earning)

actions \
  action(:detail, :get, detail_earnings_path)
  .field(:pay_period_id,
         :text,
         value: earning.pay_period_id)
  .field(:user_id, :text,
         value:    @user.id)
