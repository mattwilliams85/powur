siren json

klass :session, :anonymous

json.properties do
  json.latest_terms ApplicationAgreement.current
  json.join_grid_step1_youtube_embed_url(
    SystemSettings.get!('join_grid_step1_youtube_embed_url'))
  json.join_grid_step2_youtube_embed_url(
    SystemSettings.get!('join_grid_step2_youtube_embed_url'))
  json.preview_video_embed_url(
    SystemSettings.get!('preview_video_embed_url'))
end

actions_list = [
  action(:create, :post, login_path)
    .field(:email, :email)
    .field(:password, :password)
    .field(:remember_me, :boolean),
  action(:reset_password, :post, password_path)
    .field(:email, :email) ]

actions(*actions_list)

entity_list = [ entity(%w(solar_invite),
                       'customer-solar_invite',
                       customer_path('{code}')),
                entity(%w(grid_invite),
                       'user-solar_invite',
                       anon_invite_path('{code}')),
                entity(%w(password_token),
                       'user-password_token',
                       reset_token_password_path('{code}')) ]

entities(*entity_list)

self_link root_path
