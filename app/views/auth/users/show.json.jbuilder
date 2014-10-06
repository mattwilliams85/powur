siren json

json.partial! 'item', user: @user, detail: true

json.properties do
  @user.contact.each { |k, v| json.set! k, v }
end

links \
  link(:self, user_path(@user)),
  link(:children, downline_user_path(@user)),
  link(:ancestors, upline_user_path(@user)),
  link(:rank_acheivements, user_rank_achievements_path(@user)),
  link(:orders, user_orders_path(@user)),
  link(:order_totals, user_order_totals_path(@user)),
  link(:profile, profile_path)
