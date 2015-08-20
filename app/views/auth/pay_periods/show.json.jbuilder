siren json

klass :pay_period

json.partial! 'item', pay_period: @pay_period, detail: true

json.properties do
  json.call(@pay_period, :bonus_total)
end

entity_list = []

entity_list.push(
  entity(%w(list users),
         'pay_period-users',
         pay_period_users_path(@pay_period)))

entities(*entity_list)

action_list = []
if admin? && @pay_period.calculable?
  name = @pay_period.calculated_at? ? :recalculate : :calculate
  action_list << action(name, :post, calculate_pay_period_path(@pay_period))
end
if admin? && @pay_period.disbursable?
  action_list << action(:distribute,
                        :post,
                        distribute_pay_period_path(@pay_period))
end

actions(*action_list)

self_link pay_period_path(@pay_period)
