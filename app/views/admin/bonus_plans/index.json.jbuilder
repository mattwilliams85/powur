siren json

klass :bonus_plans, :list

json.entities @bonus_plans, partial: 'item', as: :bonus_plan

actions \
  action(:create, :post, bonus_plans_path)
    .field(:name, :text)
    .field(:start_year, :number, required: false)
    .field(:start_month, :number, required: false)

links link(:self, bonus_plans_path)
