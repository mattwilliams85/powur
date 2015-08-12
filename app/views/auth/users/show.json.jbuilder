siren json

klass :user

json.partial! 'item', user: @user

json.properties do
  json.call(@user, :address, :city, :state, :zip,
            :profile, :avatar, :avatar_file_name,
            :upline, :created_at)
  json.organic_rank rank_title(@user.organic_rank)
  json.lifetime_rank rank_title(@user.lifetime_rank)
  json.totals user_totals if params[:user_totals]
end

entities \
  entity(%w(list users), 'user-downline', downline_user_path(@user)),
  entity(%w(list users), 'user-upline', upline_user_path(@user))

action_list = []

if @user.moveable_by?(current_user)
  action_list << action(:move, :post, move_user_path(@user))
    .field(:parent_id, :select,
           required:  true,
           reference: { url:  eligible_parents_user_path(@user),
                        id:   :id,
                        name: :full_name })
end

if current_user.id == @user.id
  action_list << action(:update, :patch, user_path(@user))
    .field(:first_name, :text, value: @user.first_name)
    .field(:last_name, :text, value: @user.last_name)
    .field(:email, :email, value: @user.email)
    .field(:phone, :text, value: @user.phone)
    .field(:address, :text, value: @user.address)
    .field(:city, :text, value: @user.city)
    .field(:state, :text, value: @user.state)
    .field(:zip, :text, value: @user.zip)
    .field(:bio, :text, value: @user.bio)
    .field(:twitter_url, :text, value: @user.twitter_url)
    .field(:linkedin_url, :text, value: @user.linkedin_url)
    .field(:facebook_url, :text, value: @user.facebook_url)
end

actions(*action_list)

self_link user_path(@user)
