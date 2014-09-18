siren json

json.partial! 'item', user: @user, detail: true

json.properties do
  json.(@user, :first_name, :last_name, :email,
    :phone, :address, :city, :state, :zip)
  json
end

actions \
  action(:update, :patch, profile_path(@user)).
    field(:first_name, :text, value: @user.first_name).
    field(:last_name, :text, value: @user.last_name).
    field(:email, :email, value: @user.email).
    field(:phone, :text, value: @user.phone).
    field(:address, :text, value: @user.address).
    field(:city, :text, value: @user.city).
    field(:state, :text, value: @user.state).
    field(:zip, :text, value: @user.zip)

