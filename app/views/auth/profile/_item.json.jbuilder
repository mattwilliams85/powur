klass :user

json.rel [ :item ] unless local_assigns[:detail]

json.properties do
  json.call(@user, :first_name, :last_name, :email,
            :phone, :address, :city, :state, :zip, :provider,
            :monthly_bill, :bio, :twitter_url, :linkedin_url,
            :large_image_url, :medium_image_url, :thumb_image_url)
  json
end

#entities entity('auth/users/item', ' profile-user', user: user)

# json.properties do
#   json.call(user, :id, :first_name, :last_name, :email, :phone,
#             :address, :city, :state, :zip, :provider, :monthly_bill,
#             :bio, :twitter_url, :linkedin_url, :facebook_url)
# end


links link(:self, user_path(user))
