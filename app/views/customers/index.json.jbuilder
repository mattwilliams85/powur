siren json

klass :customers, :list

json.entities @customers, partial: 'item', as: :customer

actions \
  action(:create, :post, customers_path).
    field(:first_name, :text).
    field(:last_name, :text).
    field(:email, :email, required: false).
    field(:phone, :text, required: false).
    field(:address, :text, required: false).
    field(:city, :text, required: false).
    field(:state, :text, required: false).
    field(:zip, :text, required: false).
    field(:utility, :text, required: false).
    field(:rate_schedule, :number, required: false).
    field(:kwh, :number, required: false).
    field(:roof_material, :text, required: false).
    field(:roof_age, :number, required: false)

links \
  link(:self, customers_path)