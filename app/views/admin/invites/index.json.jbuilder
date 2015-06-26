siren json

invites_json.list_init

actions \
  index_action(admin_user_invites_path, true),
  action(:create, :post, admin_user_invites_path)
  .field(:email, :email)
  .field(:first_name, :text)
  .field(:last_name, :text)
  .field(:phone, :text, required: false),
  action(:award, :patch, admin_user_invites_path)
  .field(:invites, :number, required: true)

self_link admin_user_invites_path