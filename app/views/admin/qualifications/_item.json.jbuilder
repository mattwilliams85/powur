klass :qualification

qual_json.properties(qualification)

action_list = [
  action(:delete, :delete, qualification_path(qualification)) ]

action_list << action(:update, :patch, qualification_path(qualification))
    .field(:time_period, :select,
           options: Qualification.enum_options(:time_periods),
           value:   qualification.time_period)
    .field(:quantity, :number, value: qualification.quantity)

if qualification.is_a?(GroupSalesQualification)
  action_list.last.field(:max_leg_percent, :number,
                         value: qualification.max_leg_percent)
end

actions(*action_list)

self_link qualification_path(qualification)
