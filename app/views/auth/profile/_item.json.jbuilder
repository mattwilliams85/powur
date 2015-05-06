klass :user

json.rel [ :item ] unless local_assigns[:detail]

json.properties do
  json.call(@user, :id, :first_name, :last_name, :email,
            :phone, :address, :city, :state, :zip,
            :bio, :twitter_url, :facebook_url, :linkedin_url,
            :lifetime_rank, :organic_rank)

  json.avatar do
    [ :thumb, :preview, :large ].each do |key|
      json.set! key, user.avatar.url(key)
    end
  end if @user.avatar?
  json.is_admin user.role?(:admin)

  # Uncomment this to have front-end FIT class completion validation
  # json.require_enrollment user.require_class_completion?
  json.require_enrollment false
end

# entities entity('auth/users/item', ' profile-user', user: user)

# json.properties do
#   json.call(user, :id, :first_name, :last_name, :email, :phone,
#             :address, :city, :state, :zip, :provider, :monthly_bill,
#             :bio, :twitter_url, :linkedin_url, :facebook_url)
# end

links link(:self, user_path(user))
