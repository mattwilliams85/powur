siren json

json.properties do
  json.state @invite.mandrill.try(:state)
  json.state_description @invite.mandrill.try(:state_description)
  json.opens @invite.mandrill.try(:opens)
  json.clicks @invite.mandrill.try(:clicks)
end
