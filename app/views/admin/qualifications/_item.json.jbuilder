klass :qualification

json.properties do
  json.type qualification.type_string
  json.(qualification, :id, :type_display, :path, :time_period, :quantity)
  json.max_leg_percent(qualification.max_leg_percent) if qualification.is_a?(GroupSalesQualification)
  json.product qualification.product.name
end

action_list = [
  action(:delete, :delete, qualification_path(qualification)) ]

action_list << action(:update, :patch, 
  qualification_path(qualification)).
    field(:time_period, :select, options: Qualification::enum_options(:time_periods), 
      value: qualification.time_period).
    field(:quantity, :number, value: qualification.quantity)

if qualification.is_a?(GroupSalesQualification)
  action_list.last.field(:max_leg_percent, :number, value: qualification.max_leg_percent)
end

actions *action_list

links \
  link :self, qualification_path(qualification)