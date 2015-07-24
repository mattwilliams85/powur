siren json

users_json.item_init

json.properties do
  json.call(@user, :id, :first_name, :last_name)

  json.metrics do
    json.data0 @downline
  end
  json.avatar do
    [ :thumb, :medium, :large ].each do |key|
      json.set! key, asset_path(@user.avatar.url(key))
    end
  end if @user.avatar?
  json.weekly_growth @user.weekly_growth if @user.id == current_user.id
end
