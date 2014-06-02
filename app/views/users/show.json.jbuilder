siren json

json.partial! 'item', user: @user, detail: true

json.properties do
  json.(@user, :phone, :zip)
end

links \
  link(:self, user_path(@user))