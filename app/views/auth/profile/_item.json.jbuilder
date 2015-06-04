# Deprecated in favor of sessions/show.json
# TODO: reorganize this file, will only be used to return data for the profile page

klass :user

json.rel [ :item ] unless local_assigns[:detail]

json.properties do
  json.call(@user, :id, :first_name, :last_name, :email,
            :phone, :address, :city, :state, :zip,
            :bio, :twitter_url, :facebook_url, :linkedin_url,
            :lifetime_rank, :organic_rank, :level)

  json.avatar do
    [ :thumb, :preview, :large ].each do |key|
      json.set! key, asset_path(user.avatar.url(key))
    end
  end if @user.avatar?
  json.is_admin user.role?(:admin)

  json.metrics do
    json.proposal @user.proposal_count
    json.team @user.full_downline_count
  end

  json.require_enrollment user.require_class_completion?

  unless current_user.accepted_latest_terms?
    json.latest_terms ApplicationAgreement.current
  end
end

# entities entity('auth/users/item', ' profile-user', user: user)

# json.properties do
#   json.call(user, :id, :first_name, :last_name, :email, :phone,
#             :address, :city, :state, :zip, :provider, :monthly_bill,
#             :bio, :twitter_url, :linkedin_url, :facebook_url)
# end

links link(:self, user_path(user))
