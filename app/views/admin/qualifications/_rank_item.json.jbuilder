klass :qualification

qual_json.properties(qualification)

action_list = [
  action(:delete, :delete,
         rank_qualification_path(qualification.rank, qualification)),
  action(:update, :patch,
         rank_qualification_path(qualification.rank,
                                 qualification))
    .field(:path, :text, value: qualification.path)
    .field(:time_period, :select,
           options: Qualification.enum_options(:time_periods),
           value:   qualification.time_period)
    .field(:quantity, :number, value: qualification.quantity) ]

if qualification.is_a?(GroupSalesQualification)
  action_list.last.field(:max_leg_percent,
                         :number, value: qualification.max_leg_percent)
end

actions(*action_list)

self_link rank_qualification_path(qualification.rank, qualification)
