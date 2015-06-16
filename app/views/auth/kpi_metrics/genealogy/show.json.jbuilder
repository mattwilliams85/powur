siren json

users_json.item_init

json.properties do
  json.id @user.id
  json.first_name @user.first_name
  json.last_name @user.last_name
  json.metrics do
    json.data0 @downline
  end
  json.weekly_growth @user.weekly_growth if @user.id == current_user.id
end





