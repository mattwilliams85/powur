siren json

users_json.item_init

json.properties do
  json.id @user.id
  json.first_name @user.first_name
  json.last_name @user.last_name
  json.metrics_data @user.fetch_proposal_metrics(Date.today - 30, Date.today)
  json.avatar do
    [ :thumb, :medium, :large ].each do |key|
      json.set! key, @user.avatar.url(key)
    end
  end if @user.avatar?
  json.proposal_count @user.proposal_count
end





