siren json

json.partial! 'item', user: @user, detail: true

json.properties do
  json.(@user, :first_name, :last_name, :email, 
    :phone, :address, :city, :state, :zip)
end

ents \
  ent(%w(list orders), 'user-orders', admin_user_orders_path(@user)),
  ent(%w(list order_totals), 'user-order_totals', admin_user_order_totals_path(@user))

actions \
  action(:update, :patch, admin_user_path(@user)).
    field(:first_name, :text, value: @user.first_name).
    field(:last_name, :text, value: @user.last_name).
    field(:email, :email, value: @user.email).
    field(:phone, :text, value: @user.phone).
    field(:address, :text, value: @user.address).
    field(:city, :text, value: @user.city).
    field(:state, :text, value: @user.state).
    field(:zip, :text, value: @user.zip)

links \
  link(:self, admin_user_path(@user)),
  link(:children, downline_admin_user_path(@user)),
  link(:ancestors, upline_admin_user_path(@user))
