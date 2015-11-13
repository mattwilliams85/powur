siren json

json.properties do
  if @customer.mandrill
    json.state @customer.mandrill.state
    json.state_description @customer.mandrill.state_description
    json.opens @customer.mandrill.opens
    json.clicks @customer.mandrill.clicks
  end
end
