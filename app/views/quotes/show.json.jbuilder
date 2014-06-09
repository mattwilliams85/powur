siren json

klass :quote

create_action = actions \
  action(:update, :patch, quote_path).
    field(:url_slug, :hidden, @customer.url_slug).
    field(:email, :email, value: @customer.email).
    field(:first_name, :text, value: @customer.first_name).
    field(:last_name, :text, value: @customer.last_name).
    field(:phone, :text, value: @customer.phone).
    field(:address, :text, value: @customer.address).
    field(:city, :text, value: @customer.city).
    field(:state, :email, value: @customer.state).
    field(:zip, :text, value: @custoemr.zip).
    field(:roof_material, :text, value: @customer.roof_material).
    field(:roof_age, :number, value: @customer.roof_age)

if promoter?
  create_action.field(:promoter_id, :hidden, value: promoter.id)
end

