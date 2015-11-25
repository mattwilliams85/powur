siren json

klass :leads, :list

json.entities @leads, partial: 'item', as: :lead

actions = []

actions << action(:create, :post, leads_path)
  .field(:first_name, :text)
  .field(:last_name, :text)
  .field(:phone, :text, required: false)
  .field(:email, :email, required: false)
  .field(:address, :text, required: false)
  .field(:city, :text, required: false)
  .field(:state, :text, required: false)
  .field(:zip, :text, required: false)
  .field(:confirm_existing_email, :boolean)

actions(*actions)

self_link request.path
