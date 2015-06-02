klass :agreement

json.properties do
  json.call(agreement, :id, :version, :document_path, :published_at)
end

actions \
  action(:destroy, :delete, admin_application_agreement_path(agreement)),
  action(:publish, :patch, publish_admin_application_agreement_path(agreement)),
  action(:unpublish, :patch, unpublish_admin_application_agreement_path(agreement))

links link(:self, admin_application_agreement_path(agreement))
