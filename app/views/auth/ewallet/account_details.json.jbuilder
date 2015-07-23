siren json

klass :ewallet

json.rel [ :item ] unless local_assigns[:detail]

json.properties do
  json.call(@ewallet_account_details, :eWalletID, :LastName, :FirstName, :Email,
            :IsActivated, :CustomerGuid)
end
