
klass :qualification

json.properties do
  json.type qualification.type_string
  json.(qualification, :id, :type_display, :path)
  json.product qualification.product.name
end

action_list = [
  action(:delete, :delete, rank_qualification_path(qualification.rank, qualification)) ]

json.partial! "admin/qualifications/#{qualification.type_string}", 
  qualification: qualification, action_list: action_list

links \
  link :self, rank_qualification_path(qualification.rank, qualification)