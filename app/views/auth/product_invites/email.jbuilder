siren json

json.properties do
  json.state @customer.mandrill.try(:state)
  json.state_description @customer.mandrill.try(:state_description)
  json.opens @customer.mandrill.try(:opens)
  json.clicks @customer.mandrill.try(:clicks)
end
