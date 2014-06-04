klass :customer

json.rel [ :item ] unless local_assigns[:detail]

json.properties do
  json.(customer, :id, :first_name, :last_name, :full_name, :status)
end

links \
  link :self, customer_path(customer)


