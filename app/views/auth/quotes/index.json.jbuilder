siren json

klass :quotes, :list

json.entities @quotes, partial: 'item', as: :quote

create = action(:create, :post, request.path)
  .field(:first_name, :text)
  .field(:last_name, :text)
  .field(:address, :text, required: false)
  .field(:city, :text, required: false)
  .field(:state, :text, required: false)
  .field(:zip, :text, required: false)

quotes_json.action_quote_fields(create)

actions(index_action(request.path, true), create)

self_link request.path
