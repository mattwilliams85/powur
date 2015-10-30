klass :customer

json.properties do
  json.call(invite,
            :id, :status, :first_name, :last_name, :email, :phone,
            :full_address, :notes)
  json.updated_at invite.updated_at.to_f * 1000
end

actions = []
actions << action(:update, :patch, product_invite_path(invite))
  .field(:first_name, :text, value: invite.first_name)
  .field(:last_name, :text, value: invite.last_name)
  .field(:email, :email, value: invite.email)
  .field(:phone, :text, value: invite.phone)
  .field(:address, :text, value: invite.address)
  .field(:city, :text, value: invite.city)
  .field(:state, :text, value: invite.state)
  .field(:zip, :text, value: invite.zip)
actions << action(:resend, :post, resend_product_invite_path(invite))
actions << action(:delete, :delete, product_invite_path(invite))

actions(*actions)

self_link product_invite_path(invite)
