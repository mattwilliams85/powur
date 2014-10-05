siren json

json.partial! 'item', user: @user, detail: false

json.properties do
  json.call(@user, :first_name, :last_name, :email,
            :phone, :address, :city, :state, :zip, :provider,
            :monthly_bill, :bio, :twitter_url, :linkedin_url)
  json
end

actions \
  action(:update, :patch, profile_path)
    .field(:first_name, :text, value: @user.first_name)
    .field(:last_name, :text, value: @user.last_name)
    .field(:email, :email, value: @user.email)
    .field(:phone, :text, value: @user.phone)
    .field(:address, :text, value: @user.address)
    .field(:city, :text, value: @user.city)
    .field(:state, :text, value: @user.state)
    .field(:zip, :text, value: @user.zip)
    .field(:provider, :text, value: @user. provider)
    .field(:monthly_bill, :text, value: @user.monthly_bill)
    .field(:bio, :text, value: @user. provider)
    .field(:twitter_url, :text, value: @user. twitter_url)
    .field(:linkedin_url, :text, value: @user. linkedin_url)
    .field(:facebook_url, :text, value: @user. facebook_url)
