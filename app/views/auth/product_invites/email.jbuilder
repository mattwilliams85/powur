siren json

json.properties do
  json.state(@customer.mandrill.try(:state) || 'rejected')
  json.state_description(
    @customer.mandrill.try(:state_description) ||
    I18n.t('mandrill_states.rejected'))
  json.opens(@customer.mandrill.try(:opens))
  json.clicks(@customer.mandrill.try(:clicks))
end
