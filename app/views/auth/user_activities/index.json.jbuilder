siren json

# klass :user_activities, :list

json.entities @user_activities, partial: 'item', as: :user_activity

# json.array!(@user_activities) do |user_activity|
#   json.extract! user_activity, :id, :login_event
# end
