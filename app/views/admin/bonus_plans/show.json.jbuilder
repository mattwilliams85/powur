siren json

json.partial! 'item', bonus_plan: @bonus_plan, detail: true

entities 'admin/bonuses', bonus_plan: @bonus_plan

actions \
  action(:delete, :delete, bonus_plan_path(@bonus_plan)),
  action(:update, :patch, bonus_plan_path(@bonus_plan)).
    field(:name, :text, value: @bonus_plan.name).
    field(:start_year, :number, value: @bonus_plan.start_year, required: false).
    field(:start_month, :number, value: @bonus_plan.start_month, required: false)

