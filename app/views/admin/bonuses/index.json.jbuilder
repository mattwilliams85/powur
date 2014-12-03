siren json

klass :bonuses, :list

json.properties do
end

json.entities @bonuses, partial: 'item', as: :bonus

actions \
  action(:create, :post, bonus_plan_bonuses_path(@bonus_plan))
  .field(:type, :select, options: Bonus::TYPES)
  .field(:name, :text)

links link(:self, bonus_plan_bonuses_path(@bonus_plan))
