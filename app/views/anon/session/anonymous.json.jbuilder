siren json

klass :session, :anonymous

json.properties do
  json.latest_terms ApplicationAgreement.current
end

actions_list = [
  action(:create, :post, login_path)
    .field(:email, :email)
    .field(:password, :password)
    .field(:remember_me, :boolean),
  action(:reset_password, :post, password_path)
    .field(:email, :email) ]

actions(*actions_list)

entity_list = [ entity(%w(lead),
                       'user-anon_lead',
                       anon_lead_path('{code}')),
                entity(%w(rep_invite),
                       'user-rep_invite',
                       anon_user_path('{rep_id}')),
                entity(%w(grid_invite),
                       'user-grid_invite',
                       anon_invite_path('{code}')),
                entity(%w(password_token),
                       'user-password_token',
                       reset_token_password_path('{code}')),
                entity(%w(video_assets),
                       'user-video_assets', assets_login_path) ]

entities(*entity_list)

self_link root_path
