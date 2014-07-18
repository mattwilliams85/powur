klass :qualification

json.properties do
  json.type qualification.type_string
  json.(qualification, :id, :type_display, :path, :period, :quantity)
  json.max_leg_percent(qualification.max_leg_percent) if qualification.is_a?(GroupSalesQualification)
  json.product qualification.product.name
end

action_list = [
  action(:delete, :delete, qualification_path(qualification)) ]

action_list << action(:update, :patch, 
  qualification_path(qualification)).
    field(:period, :select, options: Qualification::PERIODS, 
      value: qualification.period).
    field(:quantity, :number, value: qualification.quantity)

if qualification.is_a?(GroupSalesQualification)
  action_list.last.field(:max_leg_percent, :number, value: qualification.max_leg_percent)
end

actions *action_list

links \
  link :self, qualification_path(qualification)