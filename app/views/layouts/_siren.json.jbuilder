json.set! :class, siren.klasses

json.properties do
  if siren.object_entity?
    if siren.list_entity?
      json.items siren.entity, partial: siren.entity_partial, as: siren.klass.to_sym
    else
      json.partial! partial: siren.entity_partial
    end
  end
  
  siren.properties.each { |k,v| json.set! k, v }
end if siren.has_properties?

# json.entities siren.entities do |entity|
#   json.partial! "#{sire.klass}s/show", entity: entity
# end if siren.entities

json.actions siren.actions do |action|
  json.(action, :name)
  json.title t("entities.#{siren.klass}.#{action.name}")
  json.(action, :method, :href)
  json.type 'application/json'

  json.fields action.fields do |field|
    json.(field, :name, :type)
  end
end unless siren.actions.empty?