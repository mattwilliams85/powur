json.set! :class, klass

json.properties do
end if @resource

json.actions actions do |action|
  json.(action, :name, :title, :method, :href)
  json.type 'application/json'

  json.fields action.fields do |field|
    json.(field, :name, :type)
  end
end