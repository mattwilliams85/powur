siren json

users_json.item_init

json.properties do
  json.call(@user, :id, :first_name, :last_name)
  json.proposal_count @user.leads.converted.count

  json.metrics do
    json.data0 @proposals
    json.data1 @orders
  end
  json.avatar do
    [ :thumb, :medium, :large ].each do |key|
      json.set! key, asset_path(@user.avatar.url(key))
    end
  end if @user.avatar?
end
