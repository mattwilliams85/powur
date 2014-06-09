siren json

klass :quote

create_action = actions \
  action(:create, :post, quote_path).
    field(:first_name, :text).
    field(:last_name, :text).
    field(:email, :email).
    field(:phone, :text)
if promoter?
  create_action.field(:promoter_id, :number, value: promoter.id)
end

