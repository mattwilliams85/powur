siren json

json.partial! 'item', bonus_plan: @bonus_plan, detail: true

entities entity(%w(list bonuses),
                'bonus-plan-bonuses',
                bonus_plan_bonuses_path(@bonus_plan))

action_list =
  [ action(:update, :patch, bonus_plan_path(@bonus_plan))
      .field(:name, :text, value: @bonus_plan.name)
      .field(:start_year, :number,
             value:    @bonus_plan.start_year,
             required: false)
      .field(:start_month, :number,
             value:    @bonus_plan.start_month,
             required: false) ]

unless @bonus_plan.active_before_now?
  action_list << action(:delete, :delete, bonus_plan_path(@bonus_plan))
end

actions(*action_list)
