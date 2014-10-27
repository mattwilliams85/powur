siren json

klass :rank_achievements, :list

json.entities @rank_achievements, partial: 'item', as: :rank_achievement

actions index_action(@orders_path, true)

links link(:self, @rank_achievements_path)
