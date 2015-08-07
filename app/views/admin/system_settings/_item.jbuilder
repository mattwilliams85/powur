klass :system_setting

json.properties do
  json.id setting.id
  json.var setting.var
  json.value setting.value
end

actions \
  action(:update, :put, admin_system_setting_path(setting))
