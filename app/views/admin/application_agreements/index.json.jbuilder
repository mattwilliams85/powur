siren json

klass :agreements, :list

json.entities @agreements, partial: 'item', as: :agreement

actions \
  action(:create, :post, admin_application_agreements_path)
  .field(:version, :string)
  .field(:document_path, :string)

links link(:self, admin_application_agreements_path)
