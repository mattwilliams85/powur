siren json

users_json.item_init

json.properties do
  json.id @user.id
  json.first_name @user.first_name
  json.last_name @user.last_name
  # json.avatar do
  #   [ :thumb, :medium, :large ].each do |key|
  #     json.set! key, asset_path(@user.avatar.url(key))
  #   end
  # end if @user.avatar?
  # json.full_downline_count @user.full_downline_count
  json.weekly_growth @user.weekly_growth
end





