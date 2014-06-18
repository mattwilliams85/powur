siren json

klass :quotes, :list

json.entities @quotes, partial: 'item', as: :quote

create_action = action(:create, :post, user_quotes_path).
  field(:first_name, :text).
  field(:last_name, :text).
  field(:email, :email, required: false).
  field(:phone, :text, required: false).
  field(:address, :text, required: false).
  field(:city, :text, required: false).
  field(:state, :text, required: false).
  field(:zip, :text, required: false)

Product.default.quote_data.each do |key|
  create_action.field(key, :text, required: false)
end

actions \
  action(:search, :get, user_quotes_path).
    field(:q, :text),
  create_action

links \
  link(:self, user_quotes_path)