siren json

json.properties do
  json.state(@invite.mandrill.try(:state) || 'rejected')
  json.state_description(
    @invite.mandrill.try(:state_description) ||
    I18n.t('mandrill_states.rejected'))
  json.opens(@invite.mandrill.try(:opens))
  json.clicks(@invite.mandrill.try(:clicks))
end
