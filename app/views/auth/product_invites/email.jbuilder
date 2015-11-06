siren json

json.properties do
  json.state @customer.mandrill.try(:state)
  json.opens @customer.mandrill.try(:opens)
  json.clicks @customer.mandrill.try(:clicks)
end
