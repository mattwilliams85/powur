siren json

klass :leads, :summary

json.properties do
  json.leads @user.metrics.leads_count(:submitted, params[:days])
  json.proposals @user.metrics.leads_count(:converted, params[:days])
  json.closed @user.metrics.leads_count(:closed_won, params[:days])
  json.contracts @user.metrics.leads_count(:contracted, params[:days])
  json.installs @user.metrics.leads_count(:installed, params[:days])
end

self_link request.path
