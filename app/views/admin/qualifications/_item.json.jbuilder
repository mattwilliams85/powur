
klass :qualification

json.properties do
  json.type qualification.type_string
  json.path qualification.path
end

action_list = [
  action(:delete, :delete, rank_qualification_path(qualification.rank, qualification)) ]

json.partial! "admin/qualifications/#{qualification.type_string}", 
  qualification: qualification, action_list: action_list

links \
  link :self, rank_qualification_path(qualification.rank, qualification)