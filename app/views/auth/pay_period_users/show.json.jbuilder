siren json

klass :user

json.partial! 'item', user: @user

entity_list = [
  entity('bonus_payments',
         'user-bonus_payments',
         bonus_payments: @bonus_payments)]
if @lead_totals
  entity_list << entity('lead_totals',
                        'user-lead_totals',
                        lead_totals: @lead_totals)
end

entities(*entity_list)

self_link request.path
