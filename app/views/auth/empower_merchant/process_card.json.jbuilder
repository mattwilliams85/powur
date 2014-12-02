siren json

klass :empower_merchant

json.rel [ :item ] unless local_assigns[:detail]

json.properties do
  json.extract! @process_response
end

# links link(:self, user_path(user))
