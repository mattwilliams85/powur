siren json

klass :user

json.properties do
  json.id @user.id
  json.first_name @user.first_name
  json.last_name @user.last_name
  json.avatar do
    [ :thumb, :medium, :large ].each do |key|
      json.set! key, asset_path(@user.avatar.url(key))
    end
  end if @user.avatar?
end

actions_list = [
  action(:validate_zip, :post, validate_zip_validator_path)
    .field(:zip, :text)
    .field(:user_id, :number, value: @user.id),
  action(:create_lead, :post, anon_leads_path)
    .field(:user_id, :text, value: @user.id)
    .field(:first_name, :text)
    .field(:last_name, :text)
    .field(:email, :email)
    .field(:phone, :text)
    .field(:address, :text)
    .field(:city, :text)
    .field(:state, :text)
    .field(:zip, :text)
    .field(:average_bill, :text)
    .field(:call_consented, :boolean, value: true) ]

actions(*actions_list)
