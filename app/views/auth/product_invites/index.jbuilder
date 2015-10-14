siren json

klass :product_invites, :list

json.entities @invites, partial: 'item', as: :invite

actions action(:create, :post, request.path)
  .field(:first_name, :text)
  .field(:last_name, :text)
  .field(:email, :email)
  .field(:phone, :text, required: false)
  .field(:address, :text, required: false)
  .field(:city, :text, required: false)
  .field(:state, :text, required: false)
  .field(:zip, :text, required: false)

self_link request.path
