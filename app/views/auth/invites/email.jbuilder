siren json

json.properties do
  if @invite.mandrill
    json.state @invite.mandrill.state
    json.state_description @invite.mandrill.state_description
    json.opens @invite.mandrill.opens
    json.clicks @invite.mandrill.clicks
  end
end
