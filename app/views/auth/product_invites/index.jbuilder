siren json

klass :product_invites, :list

json.entities @invites, partial: 'item', as: :invite

json.properties do
  Customer.statuses.each_pair do |k, _v|
    json.set! k, current_user.customers.send(k.to_sym).count
  end
end

actions action(:create, :post, request.path)
  .field(:first_name, :text)
  .field(:last_name, :text)
  .field(:email, :email, required: false)
  .field(:phone, :text, required: false)
  .field(:address, :text, required: false)
  .field(:city, :text, required: false)
  .field(:state, :text, required: false)
  .field(:zip, :text, required: false)

self_link request.path
