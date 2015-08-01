klass :user

json.properties do
  json.call(@user, :id, :first_name, :last_name, :email,
            :phone, :address, :city, :state, :zip,
            :bio, :twitter_url, :facebook_url, :linkedin_url,
            :lifetime_rank, :organic_rank, :level, :partner?)

  json.avatar do
    [ :thumb, :preview, :large ].each do |key|
      json.set! key, asset_path(user.avatar.url(key))
    end
  end if @user.avatar?

  json.allow_sms @user.allow_sms != 'false'
  json.allow_system_emails @user.allow_system_emails != 'false'
  json.allow_corp_emails @user.allow_corp_emails != 'false'

  if @ewallet_details[:Email]
    json.ewallet_auto_login_url @auto_login_url
    json.ewallet_email @ewallet_details[:Email]
    json.ewallet_is_verified @ewallet_details[:IsInfoVerified]
  end
end

links link(:self, user_path(user))
