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
    json.proposal @proposal_count
    json.team @team_count
  end

  unless current_user.accepted_latest_terms?
    json.latest_terms ApplicationAgreement.current
  end

  # Hstore stores booleans as strings; below converts back to boolean
  json.watched_intro current_user.watched_intro == 'true'
end

links link(:self, user_path(user))
