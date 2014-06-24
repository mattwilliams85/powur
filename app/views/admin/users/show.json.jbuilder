siren json

json.partial! 'item', user: @user, detail: true

json.properties do
  @user.contact.each do |key, value|
    json.set! key, value
  end
end

actions \
  action(:update, :patch, admin_user_path(@user)).
    field(:q, :text),
  action(:downline, :get, downline_admin_user_path(@user)).
    field(:q, :text),
  action(:update, :get, upline_admin_user_path(@user)).
    field(:q, :text)

links \
  link(:self, admin_user_path(@user))