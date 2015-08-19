siren json

users_json.item_init

json.properties do
  json.call(@user, :id, :first_name, :last_name)
  json.team_lead_count @user.team_lead_count
  json.lead_count @user.leads.submitted.count

  json.metrics do
    json.data0 @leads
    json.data1 @proposals
    json.data2 @contracts
    json.data3 @installs
  end
  json.avatar do
    [ :thumb, :medium, :large ].each do |key|
      json.set! key, asset_path(@user.avatar.url(key))
    end
  end if @user.avatar?
end
