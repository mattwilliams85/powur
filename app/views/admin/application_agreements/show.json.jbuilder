siren json

json.partial! 'item', agreement: @agreement

actions \
  action(:update, :patch, admin_application_agreement_path(@agreement))
  .field(:version, :string, value: @agreement.version)
  .field(:document_path, :string, value: @agreement.document_path),
  action(:destroy, :delete, admin_application_agreement_path(@agreement)),
  action(:publish, :patch, publish_admin_application_agreement_path(@agreement)),
  action(:unpublish, :patch, unpublish_admin_application_agreement_path(@agreement))
